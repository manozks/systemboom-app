/* SYSTEMBOOM motion helpers: staggered entrance index + press ripple. Safe to load on every page. */
(function(){
  var RIP='.bt,.tabs button,.seg button,.mbtn,.cb,.ibtn,.ib,.bell,.th,.pg,.tg';
  document.addEventListener('pointerdown',function(e){
    var t=e.target.closest(RIP);if(!t||t.disabled)return;
    var r=t.getBoundingClientRect(),s=document.createElement('span');
    s.className='fx-rip';s.style.left=(e.clientX-r.left)+'px';s.style.top=(e.clientY-r.top)+'px';
    s.style.transform='translate(-50%,-50%)';
    if(getComputedStyle(t).position==='static')t.style.position='relative';
    t.appendChild(s);setTimeout(function(){s.remove();},650);
  },{passive:true});
  function stagger(root){
    var sel='.panel .row,.pc,.dcard,.th,.swb,.fb';
    [].forEach.call((root||document).querySelectorAll(sel),function(el,i){el.style.setProperty('--i',Math.min(i,12));});
  }
  stagger();
  new MutationObserver(function(m){
    m.forEach(function(x){[].forEach.call(x.addedNodes,function(n){if(n.nodeType===1)stagger(n.parentNode);});});
  }).observe(document.body,{childList:true,subtree:true});
})();
