window.getParagraphContent = function() {
  var articles = document.querySelectorAll('p');
  return Array.prototype.map.call(
    articles,
    function(a) {
      return a.textContent.trim();
    }
  );
}
