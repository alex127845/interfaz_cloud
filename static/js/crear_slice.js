// Mock Vis.js for testing purposes when CDN is blocked
if (typeof vis === 'undefined') {
    window.vis = {
        DataSet: function(data) {
            this.data = data || [];
            this.length = this.data.length;
            
            this.add = function(item) {
                if (Array.isArray(item)) {
                    this.data = this.data.concat(item);
                } else {
                    this.data.push(item);
                }
                this.length = this.data.length;
            };
            
            this.get = function() {
                return this.data;
            };
            
            this.getIds = function() {
                return this.data.map(function(item) { return item.id; });
            };
            
            this.forEach = function(callback) {
                this.data.forEach(callback);
            };
            
            return this;
        },
        Network: function(container, data, options) {
            this.container = container;
            this.data = data;
            this.options = options;
            
            // Create a simple visualization placeholder
            if (container) {
                container.innerHTML = '<div style="padding: 20px; text-align: center; border: 2px dashed #ccc; border-radius: 8px; background: #f8f9fa;">' +
                    '<i class="fas fa-project-diagram fa-3x mb-3" style="color: #28a745;"></i><br>' +
                    '<strong>Vista de Red</strong><br>' +
                    '<small>Nodos: ' + (data.nodes ? data.nodes.length : 0) + ', Conexiones: ' + (data.edges ? data.edges.length : 0) + '</small>' +
                    '</div>';
            }
            
            this.on = function(event, callback) {
                // Mock event handler
                if (event === 'afterDrawing') {
                    setTimeout(callback, 100);
                }
            };
            
            return this;
        }
    };
}

// Wait for vis.js to be available
function initializeApp() {
    let nodes = new vis.DataSet([]);
    let edges = new vis.DataSet([]);
    let network = null;
    let editMode = false;

    function renderNetwork() {
        var container = document.getElementById('visjsNetwork');
        var data = { nodes: nodes, edges: edges };
        var options = { 
            manipulation: { enabled: editMode },
            nodes: {
                shape: 'circle',
                size: 25,
                font: { size: 14, color: '#333333' },
                borderWidth: 2,
                color: { background: '#28a745', border: '#1e7e34' }
            },
            edges: {
                width: 2,
                color: '#848484',
                smooth: { type: 'continuous' }
            },
            physics: {
                enabled: true,
                stabilization: { enabled: true, iterations: 100 }
            }
        };
        network = new vis.Network(container, data, options);
    }

    // Generadores de topología estándar
    function generarEstrella(n, offset=nodes.length) {
        let centerId = offset;
        nodes.add({id: centerId, label: 'Centro'});
        for (let i = 1; i <= n; i++) {
            let nodeId = offset + i;
            nodes.add({id: nodeId, label: `Nodo ${nodeId}`});
            edges.add({from: centerId, to: nodeId});
        }
    }

    function generarArbol(n, offset=nodes.length) {
        let rootId = offset;
        nodes.add({id: rootId, label: 'Raíz'});
        let count = 1;
        for (let i = 1; i <= n; i++) {
            let nodeId = offset + count;
            nodes.add({id: nodeId, label: `Nodo ${nodeId}`});
            edges.add({from: rootId, to: nodeId});
            count++;
        }
    }

    function generarAnillo(n, offset=nodes.length) {
        let firstId = offset;
        let prevId = firstId;
        for (let i = 0; i < n; i++) {
            let nodeId = offset + i;
            nodes.add({id: nodeId, label: `Nodo ${nodeId}`});
            if (i > 0) edges.add({from: prevId, to: nodeId});
            prevId = nodeId;
        }
        edges.add({from: prevId, to: firstId});
    }

    // Evento para agregar topología combinada
    document.getElementById('agregarTopologia').onclick = () => {
        const tipo = document.getElementById('topologia').value;
        const n = Math.min(parseInt(document.getElementById('num_nodos').value, 10), 5);
        const offset = nodes.length ? Math.max(...nodes.getIds()) + 1 : 0;
        if (tipo === "estrella") generarEstrella(n, offset);
        else if (tipo === "arbol") generarArbol(n, offset);
        else if (tipo === "anillo") generarAnillo(n, offset);
        renderNetwork();
        updateTopologyData();
    };

    // Habilitar edición libre personalizada
    document.getElementById('habilitarPersonalizada').onclick = () => {
        editMode = true;
        renderNetwork();
    };

    function updateTopologyData() {
        document.getElementById('topology_data').value = JSON.stringify({
            nodes: nodes.get(),
            edges: edges.get()
        });
    }

    document.getElementById('create-slice-form').onsubmit = (e) => {
        updateTopologyData();
    };

    // Inicializa la red
    renderNetwork();

    // Generate VM configurations
    function generateVMConfig() {
        const numVMs = document.getElementById('num_vms').value;
        const container = document.getElementById('vm-configs');
        container.innerHTML = '';

        for (let i = 1; i <= numVMs; i++) {
            const vmCard = document.createElement('div');
            vmCard.className = 'vm-config-card';
            vmCard.innerHTML = `
                <h6><i class="fas fa-desktop me-2"></i>VM ${i}</h6>
                <div class="row">
                    <div class="col-md-3">
                        <label class="form-label">Nombre</label>
                        <input type="text" class="form-control" name="vm_${i}_name" value="VM${i}" required>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">CPU</label>
                        <input type="text" class="form-control" name="vm_${i}_cpu" value="1" required>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">RAM</label>
                        <input type="text" class="form-control" name="vm_${i}_ram" value="1GB" required>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Almacenamiento</label>
                        <input type="text" class="form-control" name="vm_${i}_storage" value="10GB" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Imagen</label>
                        <select class="form-select" name="vm_${i}_image" required>
                            <option value="ubuntu:latest">Ubuntu Latest</option>
                            <option value="centos:latest">CentOS Latest</option>
                            <option value="debian:latest">Debian Latest</option>
                            <option value="alpine:latest">Alpine Latest</option>
                        </select>
                    </div>
                </div>
            `;
            container.appendChild(vmCard);
        }
    }

    function handleVMCountChange() {
        generateVMConfig();
    }

    // Set up event handlers
    document.getElementById('num_vms').onchange = handleVMCountChange;

    // Initialize
    generateVMConfig();
}

// Wait for DOM and vis.js to be ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
        setTimeout(initializeApp, 100);
    });
} else {
    setTimeout(initializeApp, 100);
}