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