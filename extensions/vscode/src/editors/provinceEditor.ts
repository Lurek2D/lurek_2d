import * as vscode from "vscode";
import { WebviewEditor, getNonce, wrapHtml, ICONS, iconButton, panelSection, fieldInline, toolbarSep, toolbarSpacer } from "./shared.js";

export class ProvinceEditor extends WebviewEditor {
  static open(context: vscode.ExtensionContext): ProvinceEditor {
    return new ProvinceEditor(context);
  }

  private constructor(context: vscode.ExtensionContext) {
    super(context, "lurek.editor.province", "Province Editor");
  }

  protected handleMessage(msg: { type: string; [key: string]: unknown }): void {
    switch (msg.type) {
      case "exportToml":
        this.exportToml(msg.content as string, "province.toml");
        break;
      case "exportCsv":
        if (vscode.workspace.workspaceFolders) {
          const wsPath = vscode.workspace.workspaceFolders[0].uri.fsPath;
          const filePath = vscode.Uri.file(wsPath + "/content/games/strategy/eu2/prov_cols.csv");
          vscode.workspace.fs.writeFile(filePath, new TextEncoder().encode(msg.content as string));
          vscode.window.showInformationMessage("Exported prov_cols.csv");
        }
        break;
      case "loadMap":
        vscode.window.showOpenDialog({
          canSelectFiles: true,
          canSelectMany: false,
          filters: { 'Images': ['png'] }
        }).then(uri => {
          if (uri && uri[0]) {
            vscode.workspace.fs.readFile(uri[0]).then(data => {
              const base64 = Buffer.from(data).toString('base64');
              this.panel?.webview.postMessage({ type: 'mapLoaded', data: 'data:image/png;base64,' + base64 });
            });
          }
        });
        break;
    }
  }

  protected getHtml(): string {
    const nonce = getNonce();
    return wrapHtml(nonce, "Province Editor", `
      .editor-layout {
        display: grid; grid-template-columns: 48px 300px 1fr;
        grid-template-rows: auto 1fr auto; height: 100vh;
      }
      .toolbar { grid-column: 1 / -1; }
      .status-bar { grid-column: 1 / -1; }
      .config-panel { grid-row: 2; overflow-y: auto; background: var(--surface); border-right: 1px solid var(--border); padding: 8px; }
      .preview-area { grid-row: 2; display: flex; align-items: center; justify-content: center; background: var(--bg); overflow: auto; position: relative; }
      #mapCanvas { cursor: crosshair; }
      .province-list { display: flex; flex-direction: column; gap: 4px; margin-top: 8px; }
      .province-item { display: flex; align-items: center; justify-content: space-between; padding: 4px; background: var(--surface-2); border: 1px solid var(--border); border-radius: 4px; cursor: pointer; }
      .province-item:hover { background: var(--hover); }
      .province-item.active { border-color: var(--accent); background: var(--selection); }
      .color-box { width: 16px; height: 16px; border-radius: 2px; border: 1px solid rgba(255,255,255,0.2); }
      .color-info { font-size: 10px; font-family: monospace; color: var(--text-dim); }
    `, `
      <div class="editor-layout">
        <!-- Toolbar -->
        <div class="toolbar">
          <button id="btnLoadMap" class="primary">${ICONS.folder} Load Map PNG</button>
          ${toolbarSep()}
          <div class="group">
            ${iconButton('save', { id: 'btnExportToml', title: 'Export province.toml' })}
            ${iconButton('database', { id: 'btnExportCsv', title: 'Export prov_cols.csv' })}
          </div>
        </div>

        <!-- Panel -->
        <div class="config-panel">
          ${panelSection('Active Province', `
            <div id="activeProvInfo" style="display:none;">
              <div style="display:flex; align-items:center; gap: 8px; margin-bottom: 8px;">
                <div id="activeColorBox" class="color-box"></div>
                <span id="activeColorText" class="color-info"></span>
              </div>
              <div style="margin-bottom: 4px;"><label style="font-size:10px">ID:</label> <input type="number" id="provId" style="width:100%"></div>
              <div style="margin-bottom: 4px;"><label style="font-size:10px">Name:</label> <input type="text" id="provName" style="width:100%"></div>
              <div style="margin-bottom: 4px;"><label style="font-size:10px">Terrain:</label> <select id="provTerrain" style="width:100%">
                <option value="plains">Plains</option>
                <option value="forest">Forest</option>
                <option value="mountains">Mountains</option>
                <option value="hills">Hills</option>
                <option value="desert">Desert</option>
                <option value="ocean">Ocean</option>
              </select></div>
              <div style="margin-bottom: 4px;"><label style="font-size:10px">Owner:</label> <input type="text" id="provOwner" style="width:100%"></div>
              <button id="btnSaveProv" class="primary" style="width:100%; margin-top:8px">Save Province</button>
            </div>
            <div id="noActiveProv" style="color:var(--text-dim); font-size: 11px; text-align: center; padding: 20px;">
              Click on the map to select or create a province from a color.
            </div>
          `)}
          
          ${panelSection('Provinces', `
            <div class="province-list" id="provinceList"></div>
          `)}
        </div>

        <!-- Preview -->
        <div class="preview-area">
          <canvas id="mapCanvas"></canvas>
        </div>

        <!-- Status -->
        <div class="status-bar">
          <span id="statusPos">X: 0, Y: 0</span>
          <div class="sep"></div>
          <span id="statusProvinces">0 provinces</span>
        </div>
      </div>
    `, `
      let mapImage = new Image();
      let canvas = document.getElementById('mapCanvas');
      let ctx = canvas.getContext('2d', { willReadFrequently: true });
      let provinces = [];
      let activeColor = null;

      function rgbToHex(r, g, b) {
        return "#" + (1 << 24 | r << 16 | g << 8 | b).toString(16).slice(1).toUpperCase();
      }

      window.addEventListener('message', event => {
        const message = event.data;
        if (message.type === 'mapLoaded') {
          mapImage.onload = () => {
            canvas.width = mapImage.width;
            canvas.height = mapImage.height;
            ctx.drawImage(mapImage, 0, 0);
          };
          mapImage.src = message.data;
        }
      });

      document.getElementById('btnLoadMap').addEventListener('click', () => {
        vscode.postMessage({ type: 'loadMap' });
      });

      canvas.addEventListener('mousemove', (e) => {
        const rect = canvas.getBoundingClientRect();
        const x = Math.floor((e.clientX - rect.left) * (canvas.width / rect.width));
        const y = Math.floor((e.clientY - rect.top) * (canvas.height / rect.height));
        document.getElementById('statusPos').textContent = 'X: ' + x + ', Y: ' + y;
      });

      canvas.addEventListener('click', (e) => {
        if (!mapImage.src) return;
        const rect = canvas.getBoundingClientRect();
        const x = Math.floor((e.clientX - rect.left) * (canvas.width / rect.width));
        const y = Math.floor((e.clientY - rect.top) * (canvas.height / rect.height));
        
        const pixel = ctx.getImageData(x, y, 1, 1).data;
        const hex = rgbToHex(pixel[0], pixel[1], pixel[2]);
        
        selectColor(hex, pixel[0], pixel[1], pixel[2]);
      });

      function selectColor(hex, r, g, b) {
        activeColor = { hex, r, g, b };
        document.getElementById('noActiveProv').style.display = 'none';
        document.getElementById('activeProvInfo').style.display = 'block';
        document.getElementById('activeColorBox').style.backgroundColor = hex;
        document.getElementById('activeColorText').textContent = 'RGB(' + r + ',' + g + ',' + b + ') ' + hex;
        
        let existing = provinces.find(p => p.hex === hex);
        if (existing) {
          document.getElementById('provId').value = existing.id;
          document.getElementById('provName').value = existing.name;
          document.getElementById('provTerrain').value = existing.terrain;
          document.getElementById('provOwner').value = existing.owner;
        } else {
          document.getElementById('provId').value = provinces.length > 0 ? Math.max(...provinces.map(p => p.id)) + 1 : 1;
          document.getElementById('provName').value = 'New Province';
          document.getElementById('provTerrain').value = 'plains';
          document.getElementById('provOwner').value = 'none';
        }
        
        renderList();
      }

      document.getElementById('btnSaveProv').addEventListener('click', () => {
        if (!activeColor) return;
        let id = parseInt(document.getElementById('provId').value);
        let existingIdx = provinces.findIndex(p => p.hex === activeColor.hex || p.id === id);
        
        let prov = {
          id: id,
          hex: activeColor.hex,
          r: activeColor.r,
          g: activeColor.g,
          b: activeColor.b,
          name: document.getElementById('provName').value,
          terrain: document.getElementById('provTerrain').value,
          owner: document.getElementById('provOwner').value
        };
        
        if (existingIdx >= 0) {
          provinces[existingIdx] = prov;
        } else {
          provinces.push(prov);
        }
        
        renderList();
        document.getElementById('statusProvinces').textContent = provinces.length + ' provinces';
      });

      function renderList() {
        const list = document.getElementById('provinceList');
        list.innerHTML = '';
        provinces.sort((a,b) => a.id - b.id).forEach(p => {
          const item = document.createElement('div');
          item.className = 'province-item' + (activeColor && activeColor.hex === p.hex ? ' active' : '');
          item.innerHTML = '<div style="display:flex;align-items:center;gap:6px"><div class="color-box" style="background:'+p.hex+'"></div> <span>' + p.id + ' - ' + p.name + '</span></div> <span style="font-size:10px;color:var(--text-dim)">' + p.terrain + '</span>';
          item.addEventListener('click', () => selectColor(p.hex, p.r, p.g, p.b));
          list.appendChild(item);
        });
      }

      document.getElementById('btnExportToml').addEventListener('click', () => {
        let toml = '';
        provinces.forEach(p => {
          toml += '[[province]]\n';
          toml += 'id = ' + p.id + '\n';
          toml += 'name = "' + p.name + '"\n';
          toml += 'terrain = "' + p.terrain + '"\n';
          toml += 'owner = "' + p.owner + '"\n\n';
        });
        vscode.postMessage({ type: 'exportToml', content: toml });
      });

      document.getElementById('btnExportCsv').addEventListener('click', () => {
        let csv = 'r,g,b,id\n';
        provinces.forEach(p => {
          csv += p.r + ',' + p.g + ',' + p.b + ',' + p.id + '\n';
        });
        vscode.postMessage({ type: 'exportCsv', content: csv });
      });
    `);
  }
}
