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

/* animated nav icons: drawn live in the dock art's outline style, placed over the cleared spots in dock.png / ai-nav.png */
(function(){
  var P={
    home:['h','<path d="M4 11 12 4l8 7v9h-5v-6H9v6H4z"/>',47,43],
    chats:['c','<path d="M6 4.5h12a2.5 2.5 0 0 1 2.5 2.5v7.5a2.5 2.5 0 0 1-2.5 2.5h-6.5L6.5 20v-3H6a2.5 2.5 0 0 1-2.5-2.5V7A2.5 2.5 0 0 1 6 4.5z"/>',53,36],
    market:['m','<path d="M4 9.5 5.5 4h13L20 9.5M4 9.5c0 1.4 1.1 2.5 2.5 2.5S9 10.9 9 9.5c0 1.4 1.1 2.5 2.5 2.5h1c1.4 0 2.5-1.1 2.5-2.5 0 1.4 1.1 2.5 2.5 2.5S20 10.9 20 9.5M5.5 12v8h13v-8M10 20v-4.5h4V20"/>',53,40],
    profile:['p','<circle cx="12" cy="8.5" r="3.6"/><path d="M5 20c.8-4 3.6-5.8 7-5.8s6.2 1.8 7 5.8"/>',48,36]
  };
  function add(el,key){
    var d=P[key];if(!d||el.querySelector('.nvi'))return;
    var s=document.createElementNS('http://www.w3.org/2000/svg','svg');
    s.setAttribute('viewBox','0 0 24 24');s.setAttribute('class','nvi '+d[0]);s.setAttribute('aria-hidden','true');
    s.style.left='calc('+(d[2]-31)+' * var(--nu))';s.style.top='calc('+(d[3]-31)+' * var(--nu))';
    var id='nvg'+Math.random().toString(36).slice(2,7);
    s.innerHTML='<defs><linearGradient id="'+id+'" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ffffff"/><stop offset=".55" stop-color="#d4dbe2"/><stop offset="1" stop-color="#8e99a4"/></linearGradient></defs>'+
      '<g class="nb-b">'+d[1]+'</g><g class="nb-f" style="stroke:url(#'+id+')">'+d[1]+'</g>';
    el.appendChild(s);
  }
  [].forEach.call(document.querySelectorAll('nav a[aria-label]'),function(a){add(a,a.getAttribute('aria-label').toLowerCase());});
  [].forEach.call(document.querySelectorAll('.nav-hit[data-action]'),function(a){add(a,a.dataset.action);});
})();
