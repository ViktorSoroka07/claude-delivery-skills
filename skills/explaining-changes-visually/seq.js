(function () {
  // Data: COLS are the parts a request passes through; each CASE is one scenario's steps.
  // A step is an arrow {from, to: id or [ids], text, kind, res} or a note {at: id or [ids], note, kind}.
  // kind "bad" draws in the warning colour, "ok" in the success colour; res draws a dashed reply arrow.
  var COLS = window.SEQ_COLS, CASES = window.SEQ_CASES;
  var GAP = 132, X = {};
  COLS.forEach(function (c, i) { X[c.id] = 66 + i * GAP; });
  var W = 66 * 2 + (COLS.length - 1) * GAP;
  var esc = function (s) { return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;"); };
  var lines = function (t) { return [].concat(t); };
  var tsp = function (t, x) { return lines(t).map(function (l, i) { return '<tspan x="' + x + '" dy="' + (i ? 14 : 0) + '">' + esc(l) + "</tspan>"; }).join(""); };
  var colour = function (k) { return k === "bad" ? "var(--bad)" : k === "ok" ? "var(--ok)" : "var(--muted)"; };
  var fillOf = function (k) { return k === "bad" ? "var(--bad-bg)" : k === "ok" ? "var(--ok-bg)" : "var(--surface)"; };
  function draw(id) {
    var c = CASES[id], y = 62, rows = [], out = [];
    c.steps.forEach(function (s) {
      var n = lines(s.note || s.text).length, h = s.note ? 10 + n * 14 : 16 + n * 14;
      rows.push({ s: s, y: y, h: h }); y += h + 12;
    });
    var H = y + 6;
    COLS.forEach(function (col) {
      var x = X[col.id], dim = (c.dim || []).indexOf(col.id) >= 0;
      out.push('<g opacity="' + (dim ? 0.35 : 1) + '"><rect class="box" x="' + (x - 60) + '" y="6" width="120" height="42" rx="8"/>' +
        '<text x="' + x + '" y="24" text-anchor="middle" font-weight="600" font-size="13">' + esc(col.name) + "</text>" +
        '<text x="' + x + '" y="40" text-anchor="middle" class="sub" font-size="11">' + esc(col.sub) + "</text>" +
        '<line x1="' + x + '" y1="48" x2="' + x + '" y2="' + H + '" stroke="var(--line)" stroke-dasharray="3 4"/></g>');
    });
    rows.forEach(function (r) {
      var s = r.s, k = colour(s.kind);
      if (s.note) {
        lines(s.at).forEach(function (at) {
          var x = X[at];
          out.push('<rect x="' + (x - 62) + '" y="' + r.y + '" width="124" height="' + r.h + '" rx="6" fill="' + fillOf(s.kind) + '" stroke="' + k + '"/>' +
            '<text x="' + x + '" y="' + (r.y + 15) + '" text-anchor="middle" font-size="11.5">' + tsp(s.note, x) + "</text>");
        });
        return;
      }
      var x1 = X[s.from], targets = lines(s.to), ya = r.y + r.h - 5;
      var far = targets.reduce(function (a, t) { return Math.abs(X[t] - x1) > Math.abs(X[a] - x1) ? t : a; });
      var x2 = X[far], dir = x2 > x1 ? -1 : 1, mid = x1 + (x2 - x1) / (targets.length > 1 ? 2 * targets.length : 2);
      out.push('<line x1="' + x1 + '" y1="' + ya + '" x2="' + (x2 + dir * 2) + '" y2="' + ya + '" stroke="' + k + '" stroke-width="1.6"' + (s.res ? ' stroke-dasharray="5 4"' : "") + "/>");
      targets.forEach(function (t) {
        var xt = X[t] + dir * 2;
        out.push('<path d="M' + xt + "," + ya + " l" + (dir * 8) + ",-4 l0,8 z" + '" fill="' + k + '"/>');
      });
      out.push('<text x="' + mid + '" y="' + (r.y + 11) + '" text-anchor="middle" font-size="11.5" fill="' + k + '">' + tsp(s.text, mid) + "</text>");
    });
    document.getElementById("seq").innerHTML = '<svg viewBox="0 0 ' + W + " " + H + '" style="min-width:' + W + 'px" xmlns="http://www.w3.org/2000/svg">' + out.join("") + "</svg>";
    document.getElementById("case-cap").textContent = c.cap;
    document.querySelectorAll(".tabs button").forEach(function (b) { b.setAttribute("aria-pressed", String(b.dataset.case === id)); });
  }
  document.querySelectorAll(".tabs button").forEach(function (b) { b.addEventListener("click", function () { draw(b.dataset.case); }); });
  draw(document.querySelector(".tabs button").dataset.case);
})();
