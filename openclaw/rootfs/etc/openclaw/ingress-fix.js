(function(){
  var p = location.pathname;
  if (p.indexOf("/hassio/ingress/") === 0 || p.indexOf("/api/hassio_ingress/") === 0) {
    var proto = location.protocol === "https:" ? "wss" : "ws";
    var gw = proto + "://" + location.host + p.replace(/\/$/, "");
    var k = "openclaw.control.settings.v1";
    var s;
    try { s = JSON.parse(localStorage.getItem(k) || "{}"); } catch(e) { s = {}; }
    if (s.gatewayUrl !== gw) {
      s.gatewayUrl = gw;
      localStorage.setItem(k, JSON.stringify(s));
      location.reload();
    }
  }
})();
