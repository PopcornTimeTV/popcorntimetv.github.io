
function httpGetAsync(theUrl, callback) {
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.onreadystatechange = function() {
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
    callback(JSON.parse(xmlHttp.responseText));
  }
  xmlHttp.open("GET", theUrl, true); // true for asynchronous
  xmlHttp.send(null);
}
function formatDate(date) {
  var d1 = Date.parse(date);
  var d = new Date(d1);
  var curr_date = d.getDate();
  if (curr_date.toString().length == 1) {
      curr_date = "0" + curr_date;
  }
  var curr_month = d.getMonth();
  curr_month++;
  if (curr_month.toString().length == 1) {
      curr_month = "0" + curr_month;
  }
  var curr_year = d.getFullYear();
  return " (" + curr_date + "/" + curr_month + "/" + curr_year + ")";
}
function httpResponse(json) {
  for (i = 0; i<json.length; i++) {
    var version = "VERSION " + json[i]["tag_name"] + formatDate(json[i]["published_at"]);
    var changes = json[i]["body"];
    var panel = document.createElement("panel");
    var fieldset = document.createElement("fieldset");
    var label = document.createElement("label");
    var div = document.createElement("div");
    document.getElementsByClassName("iOS")[0].appendChild(panel);
    panel.appendChild(label);
    label.appendChild(document.createTextNode(version));
    panel.appendChild(fieldset);
    fieldset.appendChild(div);
    var converter = new showdown.Converter();
    var html = converter.makeHtml(changes);
    div.innerHTML = html;
  }
}
