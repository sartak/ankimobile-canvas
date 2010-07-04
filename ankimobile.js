function add_canvas (id) {
    if (!document.getElementById(id)) {
        return;
    }
    document.getElementById(id).innerHTML = '<canvas id="ianki_webcanvas" height="250" width="250">canvas</canvas><ul class="canvas_links"> <li><a href="#" onclick="document.webcanvas.clear();">clear</a></li> <li><a href="#" onclick="document.webcanvas.revertStroke();">undo stroke</a></li> <li><a href="#" onclick="document.webcanvas.replay();">replay</a></li></ul>';

    document.webcanvas = null;
    var canvas = document.getElementById("ianki_webcanvas");
    if (canvas.getContext) {
        document.webcanvas = new WebCanvas(canvas);
        document.webcanvas.draw();
    }
}

Ti.App.addEventListener("showQuestion1", function () { add_canvas("canvas") })
Ti.App.addEventListener("showQuestion2", function () { add_canvas("canvas") })

