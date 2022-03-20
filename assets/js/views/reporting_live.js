//import "../../vendor/leaflet/leaflet.css"
import L from "../../vendor/leaflet/leaflet"

export default class ReportingLiveView { 
    mount () {
        this.map_container = document.getElementById("map-container");
        this.map = document.getElementById("map").map;
        window.onresize = this.resizeMap;
        this.resizeMap();
    }

    resizeMap() {
        this.map_container = document.getElementById("map-container");
        this.map = document.getElementById("map").map;
        
        this.map_container.style.width = window.innerWidth + "px";
        this.map_container.style.height = window.innerHeight + "px";

        this.map.invalidateSize(true);
    }

    update () {
        this.resizeMap();
    }

    unmount() {

    }
}
