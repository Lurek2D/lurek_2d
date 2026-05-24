import * as vscode from "vscode";
import { WebviewEditor, getNonce, wrapHtml, ICONS, iconButton, panelSection, fieldInline, toolbarSep, toolbarSpacer } from "./shared.js";

export class GlobeEditor extends WebviewEditor {
  static open(context: vscode.ExtensionContext): GlobeEditor {
    return new GlobeEditor(context);
  }

  private constructor(context: vscode.ExtensionContext) {
    super(context, "lurek.editor.globe", "Globe Editor");
  }

  protected handleMessage(msg: { type: string; [key: string]: unknown }): void {
    switch (msg.type) {
      case "exportLua":
        this.exportLua(msg.content as string, "globe_setup.lua");
        break;
    }
  }

  protected getHtml(): string {
    const nonce = getNonce();
    return wrapHtml(nonce, "Geoscape Map Editor", `
      :root {
        --hud-bg: #050b14;
        --hud-border: #132a4a;
        --hud-glow: rgba(0, 240, 255, 0.15);
        --hud-cyan: #00f0ff;
        --hud-green: #39ff14;
        --hud-red: #ff3344;
        --hud-amber: #ffaa00;
        --font-mono: "Fira Code", "Courier New", monospace;
      }
      
      .editor-layout {
        display: grid; 
        grid-template-columns: 48px 320px 1fr;
        grid-template-rows: auto 1fr auto; 
        height: 100vh;
        background: #02050a;
        color: #e2e8f0;
        font-family: var(--font-mono);
      }
      
      .toolbar { 
        grid-column: 1 / -1; 
        background: var(--hud-bg); 
        border-bottom: 2px solid var(--hud-border);
        padding: 8px 12px;
        display: flex;
        align-items: center;
        gap: 8px;
        box-shadow: 0 2px 10px var(--hud-glow);
        z-index: 10;
      }
      
      .toolbar button {
        background: rgba(0, 240, 255, 0.05);
        border: 1px solid var(--hud-border);
        color: var(--hud-cyan);
        padding: 6px 14px;
        font-family: var(--font-mono);
        font-size: 11px;
        font-weight: bold;
        cursor: pointer;
        border-radius: 4px;
        transition: all 0.2s ease;
      }
      
      .toolbar button:hover {
        background: rgba(0, 240, 255, 0.2);
        border-color: var(--hud-cyan);
        box-shadow: 0 0 8px var(--hud-glow);
      }
      
      .toolbar button.active {
        background: var(--hud-cyan);
        color: #000;
        border-color: var(--hud-cyan);
        box-shadow: 0 0 12px var(--hud-cyan);
      }
      
      .status-bar { 
        grid-column: 1 / -1; 
        background: var(--hud-bg);
        border-top: 1px solid var(--hud-border);
        padding: 4px 12px;
        font-size: 11px;
        color: #a0aec0;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .config-panel { 
        grid-row: 2; 
        overflow-y: auto; 
        background: var(--hud-bg); 
        border-right: 2px solid var(--hud-border); 
        padding: 12px; 
        display: flex;
        flex-direction: column;
        gap: 12px;
        z-index: 5;
      }
      
      .preview-area { 
        grid-row: 2; 
        position: relative; 
        background: #010307; 
        overflow: hidden; 
        display: flex; 
        align-items: center; 
        justify-content: center; 
      }
      
      #globeCanvas { 
        display: block;
        width: 100%;
        height: 100%;
        background: transparent;
      }
      
      .section-title {
        color: var(--hud-cyan);
        font-size: 11px;
        font-weight: bold;
        text-transform: uppercase;
        letter-spacing: 1px;
        border-bottom: 1px solid var(--hud-border);
        padding-bottom: 4px;
        margin-bottom: 8px;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .form-group {
        margin-bottom: 8px;
      }
      
      .form-group label {
        display: block;
        font-size: 9px;
        color: #718096;
        margin-bottom: 4px;
        text-transform: uppercase;
      }
      
      .form-group input, .form-group select {
        width: 100%;
        background: rgba(0, 0, 0, 0.4);
        border: 1px solid var(--hud-border);
        color: #fff;
        padding: 6px;
        font-family: var(--font-mono);
        font-size: 11px;
        border-radius: 4px;
        box-sizing: border-box;
      }
      
      .form-group input:focus, .form-group select:focus {
        border-color: var(--hud-cyan);
        outline: none;
        box-shadow: 0 0 5px rgba(0, 240, 255, 0.3);
      }
      
      .tools-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 6px;
        margin-bottom: 8px;
      }
      
      .tool-btn {
        background: rgba(19, 42, 74, 0.2);
        border: 1px solid var(--hud-border);
        color: #a0aec0;
        padding: 8px;
        font-size: 10px;
        text-align: center;
        cursor: pointer;
        border-radius: 4px;
        transition: all 0.2s;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 4px;
      }
      
      .tool-btn:hover {
        border-color: var(--hud-cyan);
        color: #fff;
        background: rgba(0, 240, 255, 0.05);
      }
      
      .tool-btn.active {
        border-color: var(--hud-green);
        color: var(--hud-green);
        background: rgba(57, 255, 20, 0.08);
        box-shadow: 0 0 8px rgba(57, 255, 20, 0.15);
      }
      
      .list-container {
        max-height: 200px;
        overflow-y: auto;
        border: 1px solid var(--hud-border);
        background: rgba(0, 0, 0, 0.3);
        border-radius: 4px;
      }
      
      .list-item { 
        display: flex; 
        justify-content: space-between; 
        align-items: center; 
        font-size: 10px; 
        padding: 6px 8px; 
        border-bottom: 1px solid var(--hud-border);
      }
      
      .list-item:hover {
        background: rgba(0, 240, 255, 0.03);
      }
      
      .list-item-info {
        display: flex;
        flex-direction: column;
        gap: 2px;
        cursor: pointer;
        flex-grow: 1;
      }
      
      .list-item button { 
        background: none; 
        border: none; 
        color: #a0aec0; 
        cursor: pointer; 
        padding: 2px 6px;
        font-size: 11px;
      }
      
      .list-item button:hover { 
        color: var(--hud-red); 
      }
      
      .badge {
        font-size: 8px;
        padding: 1px 4px;
        border-radius: 3px;
        font-weight: bold;
        text-transform: uppercase;
        display: inline-block;
      }
    `, `
      <div class="editor-layout">
        <!-- Panel górny -->
        <div class="toolbar">
          <div style="font-weight:bold; color:var(--hud-cyan); font-size:12px; margin-right:12px; letter-spacing: 1px;">DIGITAL TWIN: GEOSCAPE</div>
          <button id="btnView3D" class="active">POGLĄD GLOBUS 3D</button>
          <button id="btnView2D">EDYCJA MAPA 2D</button>
          ${toolbarSep()}
          <button id="btnPlayAuto" style="border-color: var(--hud-amber); color: var(--hud-amber);">Autorotacja</button>
          ${toolbarSpacer()}
          <button id="btnExportLua" style="border-color: var(--hud-green); color: var(--hud-green);">${ICONS.save} Eksport LUA Setup</button>
        </div>
        
        <!-- Panel boczny konfiguracyjny (lewy) -->
        <div class="config-panel">
          <div>
            <div class="section-title">Wybór Narzędzia</div>
            <div class="tools-grid">
              <div id="toolNavigate" class="tool-btn active">
                <span>🔍</span>
                <span>Nawigacja</span>
              </div>
              <div id="toolMarker" class="tool-btn">
                <span>📍</span>
                <span>Marker (Site)</span>
              </div>
              <div id="toolArea" class="tool-btn">
                <span>⬜</span>
                <span>Obszar (Rect)</span>
              </div>
              <div id="toolPolygon" class="tool-btn">
                <span>📐</span>
                <span>Teren (Polygon)</span>
              </div>
            </div>
          </div>
          
          <div>
            <div class="section-title">Właściwości Elementu</div>
            
            <div class="form-group">
              <label>Etykieta elementu:</label>
              <input type="text" id="elemLabel" value="Sektor Alpha">
            </div>
            
            <div id="markerSettings">
              <div class="form-group">
                <label>Typ taktyczny lokalizacji:</label>
                <select id="markerType">
                  <option value="player_co">Firma Gracza (Player Co)</option>
                  <option value="client">Klient (Client)</option>
                  <option value="supplier">Dostawca (Supplier)</option>
                  <option value="competitor">Konkurent (Competitor)</option>
                  <option value="partner">Partner (Partner)</option>
                  <option value="airport">Baza Lotnicza (Airport)</option>
                  <option value="port">Port morski (Port)</option>
                  <option value="train_station">Stacja Kolejowa</option>
                  <option value="mine">Kopalnia (Mine)</option>
                  <option value="power_plant">Elektrownia</option>
                </select>
              </div>
            </div>
            
            <div class="form-group">
              <label>Kolor sygnatury:</label>
              <select id="elemColor">
                <option value="#00f0ff" style="color:#00f0ff" selected>Cyan (Standard)</option>
                <option value="#39ff14" style="color:#39ff14">Zielony (Friendly)</option>
                <option value="#ff3344" style="color:#ff3344">Czerwony (Enemy)</option>
                <option value="#ffaa00" style="color:#ffaa00">Bursztynowy (Warn)</option>
                <option value="#ffffff" style="color:#ffffff">Biały (Neutral)</option>
              </select>
            </div>

            <div class="form-group">
              <label>Przyciąganie siatki (S/D):</label>
              <select id="gridSnap">
                <option value="0">Swobodne (Brak)</option>
                <option value="1">Co 1 stopień (Dokładne)</option>
                <option value="5" selected>Co 5 stopni (Standard)</option>
                <option value="10">Co 10 stopni (Zgrubne)</option>
              </select>
            </div>
          </div>
          
          <!-- Lista warstw elementów -->
          <div>
            <div class="section-title">Zapisane Warstwy <span id="elemCount" style="color:#718096; font-size:10px;">(0)</span></div>
            <div class="list-container" id="elementList"></div>
          </div>
          
          <!-- Wizualizacje HUD -->
          <div>
            <div class="section-title">Wizualizacje HUD</div>
            <div style="display:flex; flex-direction:column; gap:6px; font-size:10px;">
              <div style="display:flex; justify-content:space-between; align-items:center;">
                <span>Siatka koordynatów</span>
                <input type="checkbox" id="chkGrid" checked>
              </div>
              <div style="display:flex; justify-content:space-between; align-items:center;">
                <span>Atmosfera planety (3D)</span>
                <input type="checkbox" id="chkAtmo" checked>
              </div>
              <div style="display:flex; justify-content:space-between; align-items:center;">
                <span>Szkice lądów (wektory)</span>
                <input type="checkbox" id="chkContinents" checked>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Obszar płótna Canvas -->
        <div class="preview-area" id="previewArea">
          <canvas id="globeCanvas"></canvas>
        </div>
        
        <!-- Pasek statusu dolny -->
        <div class="status-bar">
          <span id="statusCam">Nawigacja: Aktywna</span>
          <span id="statusCursor">Lat: --, Lon: --</span>
          <span id="statusStats">Lurek2D Geoscape Engine v1.1</span>
        </div>
      </div>
    `, `
      // --- SILNIK WYKRESÓW INTERAKTYWNYCH NA CANVAS ---
      
      const canvas = document.getElementById('globeCanvas');
      const ctx = canvas.getContext('2d');
      
      let is3D = true;
      let CX = 250;
      let CY = 250;
      let R = 180; // Promień globusa bazowy
      
      // Sterowanie kamerą / widokiem 3D
      let camLat = 20;
      let camLon = 15;
      let zoom3D = 1.0;
      
      // Sterowanie kamerą / widokiem 2D
      let zoom2D = 1.0;
      let panX = 0;
      let panY = 0;
      
      let autoRotating = false;
      let activeTool = "view"; // "view", "marker", "area", "polygon"
      let dragStart = null;
      
      // Elementy i ich współrzędne geograficzne
      let elements = [];
      
      // Pomocnicze zmienne stanowe rysowania wielokątów/prostokątów
      let activeDrawingPoints = []; // [{lat, lon}]
      let activeAreaStart = null;   // {lat, lon}
      let cursorLatLon = { lat: 0, lon: 0, inside: false };
      
      // Zredukowana wektorowa mapa konturów kontynentów dla czytelności na czarnym tle
      const continents = [
        {
          name: "Ameryka Północna",
          points: [[72,-125],[69,-110],[62,-100],[50,-125],[40,-123],[32,-115],[25,-110],[19,-104],[16,-95],[20,-90],[25,-80],[25,-75],[32,-65],[45,-60],[48,-55],[55,-60],[65,-60],[72,-75],[75,-85],[70,-100]]
        },
        {
          name: "Ameryka Południowa",
          points: [[10,-72],[8,-80],[-2,-80],[-5,-75],[-12,-77],[-18,-70],[-35,-72],[-45,-73],[-54,-68],[-50,-65],[-42,-64],[-34,-52],[-22,-42],[-10,-37],[-5,-35],[5,-55],[10,-72]]
        },
        {
          name: "Afryka",
          points: [[36,10],[30,32],[15,38],[5,48],[-15,38],[-25,32],[-34,18],[-33,14],[-28,15],[-15,8],[-10,-10],[5,-10],[10,-15],[5,-13],[15,-17],[32,-16],[35,0]]
        },
        {
          name: "Eurazja",
          points: [[71,20],[75,60],[70,100],[73,140],[70,170],[55,160],[40,140],[42,120],[32,120],[25,100],[10,105],[12,78],[24,70],[15,45],[30,35],[40,26],[38,-9],[50,-5],[60,5],[65,-10],[71,5]]
        },
        {
          name: "Australia",
          points: [[-22,114],[-14,125],[-11,136],[-15,143],[-25,153],[-38,150],[-37,140],[-31,115],[-22,114]]
        },
        {
          name: "Grenlandia",
          points: [[75,-70],[83,-60],[80,-20],[70,-20],[60,-45],[65,-55]]
        }
      ];

      // Dopasowywanie płótna
      function resizeCanvas() {
        const container = document.getElementById('previewArea');
        canvas.width = container.clientWidth;
        canvas.height = container.clientHeight;
        CX = canvas.width / 2;
        CY = canvas.height / 2;
        R = Math.min(canvas.width, canvas.height) * 0.38;
        render();
      }
      window.addEventListener('resize', resizeCanvas);

      // --- MATEMATYKA PROJEKCJI I PRZELICZEŃ ---

      // Rotacja 3D
      function getRotated3D(lat, lon) {
        const radLat = lat * Math.PI / 180;
        const radLon = (lon - camLon) * Math.PI / 180;
        const cRadLat = camLat * Math.PI / 180;
        
        const x = Math.cos(radLat) * Math.sin(radLon);
        const y = Math.sin(radLat);
        const z = Math.cos(radLat) * Math.cos(radLon);
        
        const rx = x;
        const ry = y * Math.cos(cRadLat) - z * Math.sin(cRadLat);
        const rz = y * Math.sin(cRadLat) + z * Math.cos(cRadLat);
        
        return { x: rx, y: ry, z: rz };
      }

      // Rzutowanie na ekran sfery 3D
      function project3D(lat, lon) {
        const rot = getRotated3D(lat, lon);
        const currentR = R * zoom3D;
        return {
          x: CX + rot.x * currentR,
          y: CY - rot.y * currentR,
          z: rot.z,
          visible: rot.z >= 0
        };
      }

      // Rzutowanie na ekran mapy 2D (cylindryczna równoodległościowa)
      function project2D(lat, lon) {
        const wBase = R * 2.8;
        const hBase = R * 1.4;
        
        const x = CX + (lon / 180) * wBase * zoom2D + panX;
        const y = CY - (lat / 90) * hBase * zoom2D + panY;
        
        return { x, y, visible: true };
      }

      // Rzutowanie wsteczne ekranu na mapę 2D (Lat/Lon)
      function unproject2D(screenX, screenY) {
        const wBase = R * 2.8;
        const hBase = R * 1.4;
        
        let lon = ((screenX - CX - panX) / (wBase * zoom2D)) * 180;
        let lat = ((CY - screenY + panY) / (hBase * zoom2D)) * 90;
        
        lat = Math.max(-90, Math.min(90, lat));
        lon = Math.max(-180, Math.min(180, lon));
        
        return { lat, lon };
      }

      // Linia sferyczna 3D przycinana do krawędzi horyzontu (z = 0)
      function drawSphereLine(lat1, lon1, lat2, lon2, color, lineWidth, dashed = false) {
        const p1 = getRotated3D(lat1, lon1);
        const p2 = getRotated3D(lat2, lon2);
        const currentR = R * zoom3D;
        
        ctx.strokeStyle = color;
        ctx.lineWidth = lineWidth;
        ctx.beginPath();
        if (dashed) ctx.setLineDash([4, 4]);
        else ctx.setLineDash([]);
        
        if (p1.z >= 0 && p2.z >= 0) {
          ctx.moveTo(CX + p1.x * currentR, CY - p1.y * currentR);
          ctx.lineTo(CX + p2.x * currentR, CY - p2.y * currentR);
          ctx.stroke();
        } else if (p1.z >= 0 || p2.z >= 0) {
          const t = p1.z / (p1.z - p2.z);
          const ix = p1.x + t * (p2.x - p1.x);
          const iy = p1.y + t * (p2.y - p1.y);
          
          if (p1.z >= 0) {
            ctx.moveTo(CX + p1.x * currentR, CY - p1.y * currentR);
            ctx.lineTo(CX + ix * currentR, CY - iy * currentR);
          } else {
            ctx.moveTo(CX + ix * currentR, CY - iy * currentR);
            ctx.lineTo(CX + p2.x * currentR, CY - p2.y * currentR);
          }
          ctx.stroke();
        }
        ctx.setLineDash([]);
      }

      // --- RENDERING GRAFICZNY ELEMENTÓW ---

      // Siatka geograficzna
      function drawGrid() {
        if (is3D) {
          ctx.strokeStyle = "rgba(0, 240, 255, 0.08)";
          for (let l = -75; l <= 75; l += 15) {
            for (let lon = -180; lon < 180; lon += 5) {
              drawSphereLine(l, lon, l, lon + 5, "rgba(0, 240, 255, 0.08)", 1);
            }
          }
          for (let lon = -180; lon < 180; lon += 15) {
            for (let lat = -90; lat < 90; lat += 5) {
              drawSphereLine(lat, lon, lat + 5, lon, "rgba(0, 240, 255, 0.08)", 1);
            }
          }
        } else {
          ctx.strokeStyle = "rgba(0, 240, 255, 0.05)";
          ctx.lineWidth = 1;
          for (let lat = -90; lat <= 90; lat += 15) {
            const pS = project2D(lat, -180);
            const pE = project2D(lat, 180);
            ctx.beginPath();
            ctx.moveTo(pS.x, pS.y);
            ctx.lineTo(pE.x, pE.y);
            ctx.stroke();
          }
          for (let lon = -180; lon <= 180; lon += 15) {
            const pS = project2D(-90, lon);
            const pE = project2D(90, lon);
            ctx.beginPath();
            ctx.moveTo(pS.x, pS.y);
            ctx.lineTo(pE.x, pE.y);
            ctx.stroke();
          }
        }
      }

      // Kontury lądów
      function drawContinents() {
        if (!document.getElementById('chkContinents').checked) return;
        
        continents.forEach(cont => {
          for (let i = 0; i < cont.points.length; i++) {
            const p1 = cont.points[i];
            const p2 = cont.points[(i + 1) % cont.points.length];
            
            if (is3D) {
              drawSphereLine(p1[0], p1[1], p2[0], p2[1], "rgba(34, 180, 100, 0.35)", 1.2);
            } else {
              const pt1 = project2D(p1[0], p1[1]);
              const pt2 = project2D(p2[0], p2[1]);
              ctx.strokeStyle = "rgba(34, 180, 100, 0.35)";
              ctx.lineWidth = 1.2;
              ctx.beginPath();
              ctx.moveTo(pt1.x, pt1.y);
              ctx.lineTo(pt2.x, pt2.y);
              ctx.stroke();
            }
          }
        });
      }

      // Zaawansowane rysowanie symboli HUD w Canvasie
      function drawTacticalMarker(x, y, type, color, size, label) {
        ctx.shadowBlur = 8;
        ctx.shadowColor = color;
        ctx.lineWidth = 2;
        ctx.strokeStyle = color;
        ctx.fillStyle = color;
        
        ctx.beginPath();
        switch (type) {
          case 'player_co':
            // Tarcza dowodzenia
            ctx.moveTo(x, y - size);
            ctx.lineTo(x + size, y - size * 0.3);
            ctx.lineTo(x + size * 0.7, y + size * 0.8);
            ctx.lineTo(x, y + size);
            ctx.lineTo(x - size * 0.7, y + size * 0.8);
            ctx.lineTo(x - size, y - size * 0.3);
            ctx.closePath();
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(x, y, size * 0.3, 0, Math.PI * 2);
            ctx.fill();
            break;
            
          case 'client':
            // Celownik okrągły
            ctx.arc(x, y, size, 0, Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(x - size * 1.3, y); ctx.lineTo(x + size * 1.3, y);
            ctx.moveTo(x, y - size * 1.3); ctx.lineTo(x, y + size * 1.3);
            ctx.stroke();
            break;
            
          case 'supplier':
            // Fabryka / Trójkąt z kominem
            ctx.moveTo(x - size, y + size);
            ctx.lineTo(x - size, y - size * 0.3);
            ctx.lineTo(x - size * 0.3, y - size * 0.3);
            ctx.lineTo(x, y - size);
            ctx.lineTo(x + size * 0.4, y - size);
            ctx.lineTo(x + size * 0.4, y + size);
            ctx.closePath();
            ctx.stroke();
            ctx.fillRect(x - size * 0.5, y, size, size * 0.6);
            break;
            
          case 'competitor':
            // Wrogie namierzenie (X w kwadracie)
            ctx.strokeRect(x - size, y - size, size * 2, size * 2);
            ctx.beginPath();
            ctx.moveTo(x - size, y - size); ctx.lineTo(x + size, y + size);
            ctx.moveTo(x + size, y - size); ctx.lineTo(x - size, y + size);
            ctx.stroke();
            break;
            
          case 'airport':
            // Lotnisko (Krzyż lotniczy)
            ctx.beginPath();
            ctx.moveTo(x, y - size * 1.2); ctx.lineTo(x, y + size);
            ctx.moveTo(x - size * 1.2, y - size * 0.2); ctx.lineTo(x + size * 1.2, y - size * 0.2);
            ctx.moveTo(x - size * 0.4, y + size * 0.6); ctx.lineTo(x + size * 0.4, y + size * 0.6);
            ctx.stroke();
            break;
            
          case 'port':
            // Kotwica
            ctx.beginPath();
            ctx.arc(x, y, size * 0.7, 0, Math.PI);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(x, y - size); ctx.lineTo(x, y + size * 0.7);
            ctx.moveTo(x - size * 0.4, y - size * 0.3); ctx.lineTo(x + size * 0.4, y - size * 0.3);
            ctx.stroke();
            break;
            
          case 'train_station':
            ctx.strokeRect(x - size * 0.8, y - size * 0.4, size * 1.6, size * 0.8);
            ctx.beginPath();
            ctx.moveTo(x - size, y + size * 0.6); ctx.lineTo(x + size, y + size * 0.6);
            ctx.stroke();
            break;
            
          case 'mine':
            ctx.beginPath();
            ctx.moveTo(x - size, y - size); ctx.lineTo(x + size, y + size);
            ctx.moveTo(x + size, y - size); ctx.lineTo(x - size, y + size);
            ctx.stroke();
            break;
            
          case 'power_plant':
            ctx.beginPath();
            ctx.moveTo(x + size * 0.3, y - size);
            ctx.lineTo(x - size * 0.5, y + size * 0.1);
            ctx.lineTo(x + size * 0.1, y + size * 0.1);
            ctx.lineTo(x - size * 0.3, y + size);
            ctx.lineTo(x + size * 0.5, y - size * 0.1);
            ctx.lineTo(x - size * 0.1, y - size * 0.1);
            ctx.closePath();
            ctx.stroke();
            break;

          default:
            ctx.arc(x, y, 4, 0, Math.PI * 2);
            ctx.fill();
        }
        
        ctx.shadowBlur = 0;
        
        if (label) {
          ctx.font = "bold 9px var(--font-mono)";
          const textW = ctx.measureText(label).width;
          ctx.fillStyle = "rgba(2, 6, 12, 0.85)";
          ctx.fillRect(x + size + 4, y - 6, textW + 8, 13);
          ctx.strokeStyle = color;
          ctx.lineWidth = 1;
          ctx.strokeRect(x + size + 4, y - 6, textW + 8, 13);
          ctx.fillStyle = "#ffffff";
          ctx.fillText(label, x + size + 8, y + 4);
        }
      }

      function hexToRgba(hex, alpha) {
        let c;
        if(/^#([A-Fa-f0-9]{3}){1,2}$/.test(hex)){
          c = hex.substring(1).split('');
          if(c.length === 3){
            c = [c[0], c[0], c[1], c[1], c[2], c[2]];
          }
          c = '0x' + c.join('');
          return 'rgba(' + [(c>>16)&255, (c>>8)&255, c&255].join(',') + ',' + alpha + ')';
        }
        return 'rgba(0, 240, 255, ' + alpha + ')';
      }

      // --- PODSTAWOWA PĘTLA RENDERUJĄCA CANVAS ---

      function render() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        
        if (is3D) {
          // 1. Kula / Ocean
          const curR = R * zoom3D;
          const showAtmo = document.getElementById('chkAtmo').checked;
          
          if (showAtmo) {
            let atmo = ctx.createRadialGradient(CX, CY, curR * 0.96, CX, CY, curR * 1.15);
            atmo.addColorStop(0, 'rgba(0, 240, 255, 0.0)');
            atmo.addColorStop(0.2, 'rgba(0, 150, 255, 0.08)');
            atmo.addColorStop(0.7, 'rgba(0, 100, 255, 0.25)');
            atmo.addColorStop(1, 'rgba(0, 0, 0, 0)');
            ctx.fillStyle = atmo;
            ctx.beginPath();
            ctx.arc(CX, CY, curR * 1.25, 0, Math.PI * 2);
            ctx.fill();
          }
          
          ctx.beginPath();
          ctx.arc(CX, CY, curR, 0, Math.PI * 2);
          ctx.fillStyle = '#020710';
          ctx.fill();
          ctx.lineWidth = 2;
          ctx.strokeStyle = '#132a4a';
          ctx.stroke();
        } else {
          // 2. Tło 2D
          ctx.fillStyle = '#010408';
          ctx.fillRect(0, 0, canvas.width, canvas.height);
          
          const wBase = R * 2.8 * zoom2D;
          const hBase = R * 1.4 * zoom2D;
          const mL = CX - wBase + panX;
          const mT = CY - hBase + panY;
          
          ctx.strokeStyle = "rgba(0, 240, 255, 0.15)";
          ctx.lineWidth = 1.5;
          ctx.strokeRect(mL, mT, wBase * 2, hBase * 2);
          ctx.fillStyle = "rgba(0, 10, 25, 0.3)";
          ctx.fillRect(mL, mT, wBase * 2, hBase * 2);
        }
        
        // Render siatki oraz kontynentów
        drawGrid();
        drawContinents();
        
        // 3. Rysowanie zapisanych obszarów (prostokątów)
        elements.forEach(elem => {
          if (elem.type === 'area') {
            const col = elem.color || '#ffaa00';
            if (is3D) {
              drawSphereLine(elem.latMin, elem.lonMin, elem.latMin, elem.lonMax, col, 1.5);
              drawSphereLine(elem.latMin, elem.lonMax, elem.latMax, elem.lonMax, col, 1.5);
              drawSphereLine(elem.latMax, elem.lonMax, elem.latMax, elem.lonMin, col, 1.5);
              drawSphereLine(elem.latMax, elem.lonMin, elem.latMin, elem.lonMin, col, 1.5);
              
              const pMid = project3D((elem.latMin+elem.latMax)/2, (elem.lonMin+elem.lonMax)/2);
              if (pMid.visible) {
                ctx.fillStyle = "rgba(255, 255, 255, 0.6)";
                ctx.font = "8px var(--font-mono)";
                ctx.fillText(elem.label, pMid.x - 20, pMid.y);
              }
            } else {
              const pStart = project2D(elem.latMax, elem.lonMin);
              const pEnd = project2D(elem.latMin, elem.lonMax);
              
              ctx.strokeStyle = col;
              ctx.lineWidth = 1.5;
              ctx.strokeRect(pStart.x, pStart.y, pEnd.x - pStart.x, pEnd.y - pStart.y);
              ctx.fillStyle = hexToRgba(col, 0.08);
              ctx.fillRect(pStart.x, pStart.y, pEnd.x - pStart.x, pEnd.y - pStart.y);
              
              ctx.fillStyle = "#ffffff";
              ctx.font = "8px var(--font-mono)";
              ctx.fillText(elem.label, pStart.x + 4, pStart.y + 11);
            }
          }
        });
        
        // 4. Rysowanie zapisanych wielokątów
        elements.forEach(elem => {
          if (elem.type === 'polygon' && elem.points.length > 0) {
            const col = elem.color || '#39ff14';
            for (let i = 0; i < elem.points.length; i++) {
              const p1 = elem.points[i];
              const p2 = elem.points[(i + 1) % elem.points.length];
              if (is3D) {
                drawSphereLine(p1.lat, p1.lon, p2.lat, p2.lon, col, 2);
              } else {
                const pt1 = project2D(p1.lat, p1.lon);
                const pt2 = project2D(p2.lat, p2.lon);
                ctx.strokeStyle = col;
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.moveTo(pt1.x, pt1.y);
                ctx.lineTo(pt2.x, pt2.y);
                ctx.stroke();
              }
            }
            
            if (!is3D && elem.points.length > 2) {
              ctx.beginPath();
              const pS = project2D(elem.points[0].lat, elem.points[0].lon);
              ctx.moveTo(pS.x, pS.y);
              for (let i = 1; i < elem.points.length; i++) {
                const pt = project2D(elem.points[i].lat, elem.points[i].lon);
                ctx.lineTo(pt.x, pt.y);
              }
              ctx.closePath();
              ctx.fillStyle = hexToRgba(col, 0.12);
              ctx.fill();
            }
          }
        });
        
        // 5. Rysowanie dynamicznych linii podczas rysowania wielokąta
        if (activeTool === 'polygon' && activeDrawingPoints.length > 0) {
          ctx.strokeStyle = 'rgba(57, 255, 20, 0.8)';
          ctx.lineWidth = 1.5;
          for (let i = 0; i < activeDrawingPoints.length - 1; i++) {
            const p1 = activeDrawingPoints[i];
            const p2 = activeDrawingPoints[i+1];
            if (is3D) {
              drawSphereLine(p1.lat, p1.lon, p2.lat, p2.lon, 'rgba(57, 255, 20, 0.8)', 1.5);
            } else {
              const pt1 = project2D(p1.lat, p1.lon);
              const pt2 = project2D(p2.lat, p2.lon);
              ctx.beginPath();
              ctx.moveTo(pt1.x, pt1.y);
              ctx.lineTo(pt2.x, pt2.y);
              ctx.stroke();
            }
          }
          
          // Gumowa nić do kursora
          const lastPt = activeDrawingPoints[activeDrawingPoints.length - 1];
          if (is3D) {
            drawSphereLine(lastPt.lat, lastPt.lon, cursorLatLon.lat, cursorLatLon.lon, 'rgba(57, 255, 20, 0.5)', 1.5, true);
          } else {
            const pt1 = project2D(lastPt.lat, lastPt.lon);
            const pt2 = project2D(cursorLatLon.lat, cursorLatLon.lon);
            ctx.beginPath();
            ctx.setLineDash([4, 4]);
            ctx.moveTo(pt1.x, pt1.y);
            ctx.lineTo(pt2.x, pt2.y);
            ctx.stroke();
            ctx.setLineDash([]);
          }
        }
        
        // Gumowa nić prostokąta obszaru
        if (activeTool === 'area' && activeAreaStart) {
          const col = '#ffaa00';
          if (is3D) {
            drawSphereLine(activeAreaStart.lat, activeAreaStart.lon, activeAreaStart.lat, cursorLatLon.lon, col, 1, true);
            drawSphereLine(activeAreaStart.lat, cursorLatLon.lon, cursorLatLon.lat, cursorLatLon.lon, col, 1, true);
            drawSphereLine(cursorLatLon.lat, cursorLatLon.lon, cursorLatLon.lat, activeAreaStart.lon, col, 1, true);
            drawSphereLine(cursorLatLon.lat, activeAreaStart.lon, activeAreaStart.lat, activeAreaStart.lon, col, 1, true);
          } else {
            const ptS = project2D(activeAreaStart.lat, activeAreaStart.lon);
            const ptE = project2D(cursorLatLon.lat, cursorLatLon.lon);
            ctx.strokeStyle = col;
            ctx.lineWidth = 1;
            ctx.setLineDash([3, 3]);
            ctx.strokeRect(ptS.x, ptS.y, ptE.x - ptS.x, ptE.y - ptS.y);
            ctx.setLineDash([]);
          }
        }
        
        // 6. Rysowanie markerów taktycznych
        elements.forEach(elem => {
          if (elem.type === 'marker') {
            let pt = is3D ? project3D(elem.lat, elem.lon) : project2D(elem.lat, elem.lon);
            if (pt.visible) {
              drawTacticalMarker(pt.x, pt.y, elem.markerType, elem.color, 7, elem.label);
            }
          }
        });
        
        // 7. Rysowanie nakładki instruktażowej HUD na Canvasie
        drawHUDOverlay();
        
        // Aktualizacja pasku statusu
        if (is3D) {
          document.getElementById('statusCam').textContent = 'Tryb: 3D Globus | Kamera: Lat: ' + camLat.toFixed(1) + '°, Lon: ' + camLon.toFixed(1) + '° | Zoom: ' + zoom3D.toFixed(1) + 'x';
        } else {
          document.getElementById('statusCam').textContent = 'Tryb: 2D Edycja | Przesunięcie: X: ' + Math.round(panX) + 'px, Y: ' + Math.round(panY) + 'px | Zoom: ' + zoom2D.toFixed(1) + 'x';
        }
      }

      // Rysowanie nakładek informacyjnych bezpośrednio na Canvasie
      function drawHUDOverlay() {
        ctx.fillStyle = "rgba(0, 240, 255, 0.8)";
        ctx.font = "bold 9px var(--font-mono)";
        
        // Podgląd wybranego narzędzia
        ctx.fillText("NARZĘDZIE: " + activeTool.toUpperCase(), 15, 25);
        
        if (activeTool === 'polygon') {
          ctx.fillStyle = "rgba(57, 255, 20, 0.9)";
          ctx.fillText("PUNKTY POLIGONU: " + activeDrawingPoints.length, 15, 40);
          ctx.fillStyle = "rgba(160, 174, 192, 0.8)";
          ctx.fillText("[KLIK]: Dodaj wierzchołek | [DBL-KLIK]: Zamknij i zapisz", 15, 55);
        } else if (activeTool === 'area') {
          ctx.fillStyle = "rgba(255, 170, 0, 0.9)";
          ctx.fillText("OBSZAR PROSTOKĄTNY", 15, 40);
          ctx.fillStyle = "rgba(160, 174, 192, 0.8)";
          ctx.fillText("[DRAG MYCHĄ]: Zakreśl prostokąt na mapie", 15, 55);
        } else if (activeTool === 'marker') {
          ctx.fillStyle = "rgba(0, 240, 255, 0.9)";
          ctx.fillText("UMIESZCZANIE MARKERA", 15, 40);
          ctx.fillStyle = "rgba(160, 174, 192, 0.8)";
          ctx.fillText("[KLIK]: Umieść marker we współrzędnych", 15, 55);
        } else {
          ctx.fillStyle = "rgba(160, 174, 192, 0.8)";
          ctx.fillText("[L-DRAG]: Nawigacja/Obrót | [WHEEL]: Zoom", 15, 40);
        }
      }

      // --- OBSŁUGA INTERAKCJI MYSZKĄ I PRZYCIĄGANIA ---

      function getSnapStep() {
        return parseInt(document.getElementById('gridSnap').value) || 0;
      }

      function snap(val, step) {
        if (step <= 0) return val;
        return Math.round(val / step) * step;
      }

      // Odpytanie o współrzędne Lat/Lon pod wskaźnikiem myszy
      function getCanvasLatLon(e) {
        const rect = canvas.getBoundingClientRect();
        const mX = e.clientX - rect.left;
        const mY = e.clientY - rect.top;
        
        if (is3D) {
          const curR = R * zoom3D;
          const rx = (mX - CX) / curR;
          const ry = (CY - mY) / curR;
          const rSq = rx * rx + ry * ry;
          
          if (rSq <= 1.0) {
            const rz = Math.sqrt(1.0 - rSq);
            const cRadLat = camLat * Math.PI / 180;
            
            const y = ry * Math.cos(cRadLat) + rz * Math.sin(cRadLat);
            const z = -ry * Math.sin(cRadLat) + rz * Math.cos(cRadLat);
            const x = rx;
            
            let lat = Math.asin(y) * 180 / Math.PI;
            let lon = Math.atan2(x, z) * 180 / Math.PI + camLon;
            
            if (lon > 180) lon -= 360;
            if (lon < -180) lon += 360;
            
            return { lat, lon, inside: true };
          }
          return { lat: 0, lon: 0, inside: false };
        } else {
          const latLon = unproject2D(mX, mY);
          return { lat: latLon.lat, lon: latLon.lon, inside: true };
        }
      }

      // Eventy myszy
      canvas.addEventListener('mousedown', e => {
        const latLon = getCanvasLatLon(e);
        
        if (activeTool === 'view' || !latLon.inside) {
          dragStart = {
            x: e.clientX,
            y: e.clientY,
            lon: camLon,
            lat: camLat,
            panX: panX,
            panY: panY
          };
        } else if (activeTool === 'marker') {
          const step = getSnapStep();
          const targetLat = snap(latLon.lat, step);
          const targetLon = snap(latLon.lon, step);
          
          elements.push({
            id: Date.now().toString(),
            type: 'marker',
            lat: targetLat,
            lon: targetLon,
            label: document.getElementById('elemLabel').value,
            markerType: document.getElementById('markerType').value,
            color: document.getElementById('elemColor').value
          });
          updateElementList();
          render();
        } else if (activeTool === 'area') {
          const step = getSnapStep();
          activeAreaStart = {
            lat: snap(latLon.lat, step),
            lon: snap(latLon.lon, step)
          };
        } else if (activeTool === 'polygon') {
          const step = getSnapStep();
          activeDrawingPoints.push({
            lat: snap(latLon.lat, step),
            lon: snap(latLon.lon, step)
          });
          render();
        }
      });

      canvas.addEventListener('mousemove', e => {
        const latLon = getCanvasLatLon(e);
        
        if (latLon.inside) {
          const step = getSnapStep();
          const dLat = snap(latLon.lat, step);
          const dLon = snap(latLon.lon, step);
          document.getElementById('statusCursor').textContent = 'Kursor: Lat: ' + dLat.toFixed(1) + '°, Lon: ' + dLon.toFixed(1) + '°';
          cursorLatLon = { lat: dLat, lon: dLon, inside: true };
        } else {
          document.getElementById('statusCursor').textContent = 'Kursor: poza mapą';
          cursorLatLon.inside = false;
        }

        if (dragStart) {
          const dx = e.clientX - dragStart.x;
          const dy = e.clientY - dragStart.y;
          
          if (is3D) {
            camLon = dragStart.lon - dx * 0.4;
            camLat = Math.max(-85, Math.min(85, dragStart.lat + dy * 0.4));
            if (camLon > 180) camLon -= 360;
            if (camLon < -180) camLon += 360;
          } else {
            panX = dragStart.panX + dx;
            panY = dragStart.panY + dy;
          }
          render();
        } else if (activeTool === 'area' && activeAreaStart) {
          render();
        } else if (activeTool === 'polygon' && activeDrawingPoints.length > 0) {
          render();
        }
      });

      window.addEventListener('mouseup', e => {
        if (activeTool === 'area' && activeAreaStart) {
          const latLon = getCanvasLatLon(e);
          if (latLon.inside) {
            const step = getSnapStep();
            const endLat = snap(latLon.lat, step);
            const endLon = snap(latLon.lon, step);
            
            const latMin = Math.min(activeAreaStart.lat, endLat);
            const latMax = Math.max(activeAreaStart.lat, endLat);
            const lonMin = Math.min(activeAreaStart.lon, endLon);
            const lonMax = Math.max(activeAreaStart.lon, endLon);
            
            if (Math.abs(latMax - latMin) > 0.1 || Math.abs(lonMax - lonMin) > 0.1) {
              elements.push({
                id: Date.now().toString(),
                type: 'area',
                latMin, latMax, lonMin, lonMax,
                label: document.getElementById('elemLabel').value,
                color: document.getElementById('elemColor').value
              });
              updateElementList();
            }
          }
          activeAreaStart = null;
          render();
        }
        dragStart = null;
      });

      // Zoomowanie bezpośrednio do pozycji kursora myszki (Dla 2D i 3D)
      canvas.addEventListener('wheel', e => {
        e.preventDefault();
        const zoomFactor = e.deltaY < 0 ? 1.15 : 0.85;
        
        if (is3D) {
          zoom3D = Math.max(0.4, Math.min(6.0, zoom3D * zoomFactor));
        } else {
          // Dla 2D robimy precyzyjny zoom celowany w kursor myszy
          const rect = canvas.getBoundingClientRect();
          const mX = e.clientX - rect.left;
          const mY = e.clientY - rect.top;
          
          const oldZoom = zoom2D;
          zoom2D = Math.max(0.25, Math.min(10.0, zoom2D * zoomFactor));
          
          // Korekta przesunięcia, aby punkt pod myszką pozostał w tym samym miejscu
          panX = mX - CX - (mX - CX - panX) * (zoom2D / oldZoom);
          panY = mY - CY - (mY - CY - panY) * (zoom2D / oldZoom);
        }
        render();
      }, { passive: false });

      // Podwójne kliknięcie zamyka wielokąt
      canvas.addEventListener('dblclick', e => {
        if (activeTool === 'polygon' && activeDrawingPoints.length > 2) {
          elements.push({
            id: Date.now().toString(),
            type: 'polygon',
            points: [...activeDrawingPoints],
            label: document.getElementById('elemLabel').value,
            color: document.getElementById('elemColor').value
          });
          activeDrawingPoints = [];
          updateElementList();
          render();
        }
      });

      // --- PANEL INTERFEJSU I AKTUALIZACJA LISTY ---

      document.getElementById('btnView3D').addEventListener('click', () => {
        is3D = true;
        document.getElementById('btnView3D').className = "active";
        document.getElementById('btnView2D').className = "";
        render();
      });

      document.getElementById('btnView2D').addEventListener('click', () => {
        is3D = false;
        document.getElementById('btnView3D').className = "";
        document.getElementById('btnView2D').className = "active";
        render();
      });

      const toolButtons = {
        'view': document.getElementById('toolNavigate'),
        'marker': document.getElementById('toolMarker'),
        'area': document.getElementById('toolArea'),
        'polygon': document.getElementById('toolPolygon')
      };

      Object.keys(toolButtons).forEach(tKey => {
        toolButtons[tKey].addEventListener('click', () => {
          Object.keys(toolButtons).forEach(k => toolButtons[k].className = "tool-btn");
          toolButtons[tKey].className = "tool-btn active";
          activeTool = tKey;
          
          document.getElementById('markerSettings').style.display = (tKey === 'marker') ? 'block' : 'none';
          activeDrawingPoints = [];
          activeAreaStart = null;
          render();
        });
      });

      function updateElementList() {
        const list = document.getElementById('elementList');
        list.innerHTML = '';
        document.getElementById('elemCount').textContent = '(' + elements.length + ')';
        
        elements.forEach(elem => {
          const item = document.createElement('div');
          item.className = 'list-item';
          
          let badgeText = elem.type;
          let badgeColor = elem.color;
          let descText = "";
          
          if (elem.type === 'marker') {
            badgeText = elem.markerType;
            descText = "[" + elem.lat.toFixed(1) + "°, " + elem.lon.toFixed(1) + "°]";
          } else if (elem.type === 'area') {
            descText = "Obszar rect";
          } else if (elem.type === 'polygon') {
            descText = "Polygon: " + elem.points.length + " pkt";
          }
          
          item.innerHTML = \`
            <div class="list-item-info">
              <span style="font-weight:bold; color:#ffffff;">\${elem.label}</span>
              <div style="display:flex; gap:6px; align-items:center;">
                <span class="badge" style="background:\${hexToRgba(badgeColor, 0.15)}; border:1px solid \${badgeColor}; color:\${badgeColor};">\${badgeText}</span>
                <span style="color:#718096; font-size:8px;">\${descText}</span>
              </div>
            </div>
            <div>
              <button class="btn-focus" style="color:var(--hud-cyan)" title="Centruj">🎯</button>
              <button class="btn-del" title="Usuń">🗑️</button>
            </div>
          \`;
          
          item.querySelector('.btn-focus').addEventListener('click', () => {
            focusOn(elem);
          });
          
          item.querySelector('.btn-del').addEventListener('click', () => {
            elements = elements.filter(x => x.id !== elem.id);
            updateElementList();
            render();
          });
          
          list.appendChild(item);
        });
      }

      function focusOn(elem) {
        let tLat = 0, tLon = 0;
        if (elem.type === 'marker') {
          tLat = elem.lat; tLon = elem.lon;
        } else if (elem.type === 'area') {
          tLat = (elem.latMin+elem.latMax)/2; tLon = (elem.lonMin+elem.lonMax)/2;
        } else if (elem.type === 'polygon' && elem.points.length > 0) {
          let sLat = 0, sLon = 0;
          elem.points.forEach(p => { sLat += p.lat; sLon += p.lon; });
          tLat = sLat / elem.points.length;
          tLon = sLon / elem.points.length;
        }
        
        if (is3D) {
          camLat = tLat;
          camLon = tLon;
          zoom3D = 1.25;
        } else {
          const wBase = R * 2.8;
          const hBase = R * 1.4;
          panX = - (tLon / 180) * wBase * zoom2D;
          panY = (tLat / 90) * hBase * zoom2D;
        }
        render();
      }

      // Autorotacja kuli
      document.getElementById('btnPlayAuto').addEventListener('click', () => {
        autoRotating = !autoRotating;
        const btn = document.getElementById('btnPlayAuto');
        if (autoRotating) {
          btn.textContent = "Stop obrót";
          btn.style.background = "var(--hud-amber)";
          btn.style.color = "#000";
          spin();
        } else {
          btn.textContent = "Autorotacja";
          btn.style.background = "rgba(0, 240, 255, 0.05)";
          btn.style.color = "var(--hud-amber)";
        }
      });

      function spin() {
        if (!autoRotating) return;
        if (is3D) {
          camLon = (camLon + 0.4) % 360;
          if (camLon > 180) camLon -= 360;
          render();
        }
        requestAnimationFrame(spin);
      }

      // --- EKSPORT DO PLIKU KONFIGURACYJNEGO LUA ---

      document.getElementById('btnExportLua').addEventListener('click', () => {
        let lua = '-- Setup Geoscape wygenerowany przez Edytor Lurek2D\n';
        lua += 'local geoscape = lurek.geoscape.new("my_geoscape", {\n';
        lua += '  show_grid = ' + (document.getElementById('chkGrid').checked ? 'true' : 'false') + ',\n';
        lua += '  show_atmo = ' + (document.getElementById('chkAtmo').checked ? 'true' : 'false') + '\n';
        lua += '})\n\n';
        
        lua += '-- --- MARKERY TAKTYCZNE ---\n';
        elements.filter(x => x.type === 'marker').forEach(m => {
          lua += 'geoscape:addMarker("' + m.id + '", ' + m.lat.toFixed(4) + ', ' + m.lon.toFixed(4) + ', {\n';
          lua += '  label = "' + m.label + '",\n';
          lua += '  markerType = "' + m.markerType + '",\n';
          lua += '  color = "' + m.color + '"\n';
          lua += '})\n';
        });
        
        lua += '\n-- --- STREFY (AREAS) ---\n';
        elements.filter(x => x.type === 'area').forEach(a => {
          lua += 'geoscape:addArea("' + a.id + '", ' + a.latMin.toFixed(4) + ', ' + a.latMax.toFixed(4) + ', ' + a.lonMin.toFixed(4) + ', ' + a.lonMax.toFixed(4) + ', {\n';
          lua += '  label = "' + a.label + '",\n';
          lua += '  color = "' + a.color + '"\n';
          lua += '})\n';
        });
        
        lua += '\n-- --- WIELOKĄTY TERENOWE (REGIONY) ---\n';
        elements.filter(x => x.type === 'polygon').forEach(p => {
          lua += 'geoscape:addPolygon("' + p.id + '", {\n';
          p.points.forEach(pt => {
            lua += '  { lat = ' + pt.lat.toFixed(4) + ', lon = ' + pt.lon.toFixed(4) + ' },\n';
          });
          lua += '}, {\n';
          lua += '  label = "' + p.label + '",\n';
          lua += '  color = "' + p.color + '"\n';
          lua += '})\n';
        });
        
        vscode.postMessage({ type: 'exportLua', content: lua });
      });

      document.getElementById('chkGrid').addEventListener('change', render);
      document.getElementById('chkAtmo').addEventListener('change', render);
      document.getElementById('chkContinents').addEventListener('change', render);

      // Inicjalizacja startowych obiektów
      elements.push({
        id: "base_hq",
        type: "marker",
        lat: 52.2,
        lon: 21.0,
        label: "POLAND HQ",
        markerType: "player_co",
        color: "#39ff14"
      });
      elements.push({
        id: "client_london",
        type: "marker",
        lat: 51.5,
        lon: -0.1,
        label: "LONDON STORAGE",
        markerType: "client",
        color: "#00f0ff"
      });

      setTimeout(() => {
        resizeCanvas();
        updateElementList();
      }, 150);
    `);
  }
}
