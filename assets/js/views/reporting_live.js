export default class ReportingLiveView { 
    view_mounted ({liveSocket}) {
        this.map_container = document.getElementById("map-container");
        this.map = document.getElementById("map").map;

        window.onresize = this.resizeMap;
        this.resizeMap();

        var view = this;
        
        liveSocket.hooks.ReportingLiveView = {
            mounted() {
                view.map.on('moveend', function () {
                    var bounds = view.map.getBounds();
                    this.pushEvent("map-bounds-update", bounds);
                }.bind(this));
            }
        };
    }

    view_unmounted() {

    }

    resizeMap() {
        this.map_container = document.getElementById("map-container");
        this.map = document.getElementById("map").map;
        
        this.map_container.style.width = window.innerWidth + "px";
        this.map_container.style.height = window.innerHeight + "px";

        this.map.invalidateSize(true);
    }

    updated () {
        this.resizeMap();
    }

}
