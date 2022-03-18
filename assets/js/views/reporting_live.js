//import "../../vendor/leaflet/leaflet.css"
import L from "../../vendor/leaflet/leaflet"

export default class ReportingLiveView { 
    mount () {
        this.map = document.getElementById("map");
        window.onresize = this.resizeMap;
        this.resizeMap();
    }

    resizeMap() {
        this.map.width = window.innerWidth;
        this.map.height = window.innerHeight;

        this.map.style.width = window.innerWidth + "px";
        this.map.style.height = window.innerHeight + "px";

        this.map.map.invalidateSize(true);
    }

    update () {
        this.resizeMap();
    }

    unmount() {

    }
}
