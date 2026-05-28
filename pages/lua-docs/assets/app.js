let searchIndexPromise;

function loadSearchIndex() {
  if (!searchIndexPromise) {
        searchIndexPromise = Promise.resolve(Array.isArray(window.LUREK_SEARCH_INDEX) ? window.LUREK_SEARCH_INDEX : []);
  }
  return searchIndexPromise;
}

function uniqueSorted(values) {
  return [...new Set(values.filter(Boolean))].sort((left, right) => left.localeCompare(right));
}

function populateFilter(select, values, placeholder) {
  const current = select.value;
  select.innerHTML = `<option value="">${placeholder}</option>`;
  for (const value of values) {
    const option = document.createElement("option");
    option.value = value;
    option.textContent = value;
    select.appendChild(option);
  }
  select.value = values.includes(current) ? current : "";
}

function renderResults(items, host) {
  if (!items.length) {
    host.hidden = true;
    host.innerHTML = "";
    return;
  }

  host.hidden = false;
  host.innerHTML = items.map((item) => {
    const href = new URL(`${window.LUREK_SITE_BASE}/${item.href}`, window.location.href).toString();
    return `
      <a class="search-result" href="${href}">
        <strong>${item.title}</strong>
        <span>${item.kind} · ${item.module || "global"} · ${item.subtitle}</span>
      </a>
    `;
  }).join("");
}

function renderPageResults(items, host) {
    if (!host) {
        return;
    }

    if (!items.length) {
        host.innerHTML = '<p class="empty-state">No entries match the current query and filters.</p>';
        return;
    }

    host.innerHTML = items.map((item) => {
        const href = new URL(`${window.LUREK_SITE_BASE}/${item.href}`, window.location.href).toString();
        return `
            <article class="api-card">
                <h3><a href="${href}">${item.title}</a></h3>
                <p>${item.subtitle}</p>
                <div class="api-meta"><span>${item.kind}</span><span>${item.module || "global"}</span></div>
            </article>
        `;
    }).join("");
}

function setSearchPageLink(link, query, selectedModule, selectedKind) {
    if (!link) {
        return;
    }

    const params = new URLSearchParams();
    if (query) {
        params.set("q", query);
    }
    if (selectedModule) {
        params.set("module", selectedModule);
    }
    if (selectedKind) {
        params.set("kind", selectedKind);
    }
    const suffix = params.toString() ? `?${params.toString()}` : "";
    link.href = `${window.LUREK_SITE_BASE}/search.html${suffix}`;
}

document.addEventListener("DOMContentLoaded", async () => {
  const input = document.getElementById("search");
  const results = document.getElementById("search-results");
  const moduleFilter = document.getElementById("filter-module");
  const kindFilter = document.getElementById("filter-kind");
    if (!input || !results || !moduleFilter || !kindFilter) {
    return;
  }

    const pageResults = document.getElementById("page-search-results");
    const summary = document.getElementById("search-summary");
    const isSearchPage = Boolean(pageResults);
    const searchLink = document.createElement("a");
    searchLink.id = "search-page-link";
    searchLink.className = "search-link";
    searchLink.textContent = "Open full search page";
    results.insertAdjacentElement("afterend", searchLink);

  const items = await loadSearchIndex();
  populateFilter(moduleFilter, uniqueSorted(items.map((item) => item.module)), "All modules");
  populateFilter(kindFilter, uniqueSorted(items.map((item) => item.kind)), "All types");

    if (isSearchPage) {
        const params = new URLSearchParams(window.location.search);
        input.value = params.get("q") || "";
        moduleFilter.value = params.get("module") || "";
        kindFilter.value = params.get("kind") || "";
    }

  const applySearch = () => {
    const query = input.value.trim().toLowerCase();
    const selectedModule = moduleFilter.value;
    const selectedKind = kindFilter.value;
        setSearchPageLink(searchLink, query, selectedModule, selectedKind);
    const filtered = items
      .filter((item) => {
        if (selectedModule && item.module !== selectedModule) {
          return false;
        }
        if (selectedKind && item.kind !== selectedKind) {
          return false;
        }
        if (!query) {
          return selectedModule || selectedKind;
        }
        const haystack = `${item.title} ${item.subtitle} ${item.keywords}`.toLowerCase();
        return haystack.includes(query);
      })
      .slice(0, 50);
    renderResults(filtered, results);

        if (isSearchPage) {
            renderPageResults(filtered, pageResults);
            if (summary) {
                summary.textContent = filtered.length
                    ? `${filtered.length} entries match the current query.`
                    : "No entries match the current query and filters.";
            }
            const params = new URLSearchParams();
            if (query) {
                params.set("q", query);
            }
            if (selectedModule) {
                params.set("module", selectedModule);
            }
            if (selectedKind) {
                params.set("kind", selectedKind);
            }
            const suffix = params.toString() ? `?${params.toString()}` : "";
            window.history.replaceState({}, "", `${window.location.pathname}${suffix}`);
        }
  };

  input.addEventListener("input", applySearch);
  moduleFilter.addEventListener("change", applySearch);
  kindFilter.addEventListener("change", applySearch);
    input.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            window.location.href = searchLink.href;
        }
    });

    if (isSearchPage) {
        applySearch();
    }

  document.addEventListener("click", (event) => {
    if (!results.contains(event.target) && event.target !== input && event.target !== moduleFilter && event.target !== kindFilter) {
      if (!input.value.trim() && !moduleFilter.value && !kindFilter.value) {
        renderResults([], results);
      }
    }
  });
});
