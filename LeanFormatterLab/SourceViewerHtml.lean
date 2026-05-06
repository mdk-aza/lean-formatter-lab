import Lean

namespace LeanFormatterLab

def sourceViewerCss : String :=
    ":root{--bg:#0a0a0f;--panel:#0d0d14;--bd:#1e1e2e;--tx:#cdd6f4;--dm:#585b70;--nd:#cba6f7;--at:#fab387;--id:#89dceb;--ad:#a6e3a1;--rm:#f38ba8;--ch:#f9e2af;--ac:#f5c2e7;--p1:#89b4fa;--p2:#f9e2af;--p3:#a6e3a1;--p4:#f5c2e7;--node-font:11px;--node-size:24px;--source-font:1.25rem;}" ++
    "*{box-sizing:border-box;margin:0;padding:0;}" ++
    "html,body{width:100%;height:100%;overflow:hidden;}" ++
    "body{background:var(--bg);color:var(--tx);font-family:'JetBrains Mono',monospace;}" ++

    "header{height:58px;position:sticky;top:0;z-index:100;padding:.55rem 1rem;border-bottom:1px solid var(--bd);display:flex;align-items:center;gap:1rem;background:#0a0a0fee;backdrop-filter:blur(8px);}" ++
    "h1{font-family:'Syne',sans-serif;font-weight:800;font-size:1rem;color:var(--ac);white-space:nowrap;}" ++
    ".trm{font-size:.68rem;color:var(--dm);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:22vw;}" ++
    ".trm span{color:var(--tx);background:var(--bd);padding:.1em .4em;border-radius:3px;}" ++

    ".ctrls{display:flex;align-items:center;gap:.5rem;font-size:.58rem;color:var(--dm);white-space:nowrap;overflow-x:auto;max-width:62vw;padding-bottom:2px;}" ++
    ".ctrl{display:flex;align-items:center;gap:.25rem;}" ++
    ".ctrl input[type=range]{width:70px;accent-color:var(--ac);}" ++
    ".ctrl span{color:var(--tx);min-width:1.8rem;display:inline-block;text-align:right;}" ++
    ".btn{border:1px solid var(--bd);background:#12121a;color:var(--tx);border-radius:5px;padding:.18rem .45rem;font-size:.58rem;font-family:'JetBrains Mono',monospace;cursor:pointer;}" ++
    ".btn:hover{border-color:var(--ac);}" ++
    ".btn.active{border-color:var(--ac);color:var(--ac);}" ++

    ".leg{margin-left:auto;display:flex;gap:.65rem;font-size:.56rem;align-items:center;white-space:nowrap;}" ++
    ".li{display:flex;align-items:center;gap:.25rem;color:var(--dm);}" ++
    ".dot{width:6px;height:6px;border-radius:50%;}" ++

    ".main{display:grid;grid-template-columns:1.25fr .75fr;grid-template-rows:42vh 1fr;gap:1px;background:var(--bd);height:calc(100vh - 58px);overflow:hidden;}" ++
    ".panel{background:var(--bg);display:flex;flex-direction:column;overflow:hidden;min-width:0;min-height:0;}" ++
    ".ph{height:34px;position:sticky;top:0;z-index:20;padding:.4rem .75rem;border-bottom:1px solid var(--bd);display:flex;align-items:center;gap:.45rem;flex-shrink:0;background:#0a0a0fee;backdrop-filter:blur(8px);}" ++
    ".pn{font-family:'Syne',sans-serif;font-weight:800;font-size:1.15rem;line-height:1;opacity:.18;}" ++
    ".pt{font-family:'Syne',sans-serif;font-weight:800;font-size:.64rem;letter-spacing:.06em;text-transform:uppercase;}" ++
    ".ps{font-size:.52rem;color:var(--dm);margin-left:auto;}" ++
    ".pb{flex:1;overflow:auto;position:relative;min-height:0;}" ++

    ".sourcePanel .pn,.sourcePanel .pt{color:var(--p1);}" ++
    ".metaPanel .pn,.metaPanel .pt{color:var(--ac);}" ++
    ".graphPanel .pn,.graphPanel .pt{color:var(--p3);}" ++
    ".graphPanel .pb{min-height:260px;}" ++
    ".tracePanel .pn,.tracePanel .pt{color:var(--p2);}" ++

    ".sourceWrap{padding:1.1rem 1.2rem;}" ++
    ".sourceIntro{font-size:.62rem;color:var(--dm);margin-bottom:.8rem;line-height:1.7;}" ++
    ".termPreview{display:inline-block;color:var(--tx);background:#11111a;border:1px solid var(--bd);border-radius:6px;padding:.12rem .45rem;margin:.15rem 0 .35rem;}" ++
    ".sourceLine{font-size:var(--source-font);line-height:2.4;white-space:normal;}" ++
    ".tok{display:inline-block;margin:.18rem .12rem;padding:.12rem .35rem;border:1px solid var(--bd);border-radius:7px;background:#11111a;cursor:pointer;transition:transform .08s,border-color .08s,background .08s;}" ++
    ".tok:hover{transform:translateY(-1px);border-color:var(--ac);}" ++
    ".tok.preserved{border-color:var(--p1);color:var(--tx);background:#0b1528;}" ++
    ".tok.lost{border-color:var(--rm);color:#ffd6df;background:#2a1018;}" ++
    ".tok.synthetic{border-color:var(--ad);color:#d5ffd9;background:#0d2414;}" ++
    ".tok.selected{outline:2px solid var(--ac);outline-offset:2px;}" ++
    ".tok.dim{opacity:.18;}" ++

    ".rangeBadge{display:inline-block;color:var(--ch);font-size:.58rem;border:1px solid #3a3144;border-radius:999px;padding:.05rem .38rem;margin-left:.35rem;}" ++

    ".meta{padding:1rem;font-size:.72rem;line-height:1.75;}" ++
    ".metaEmpty{color:var(--dm);}" ++
    ".kv{display:grid;grid-template-columns:7.5rem 1fr;gap:.3rem .6rem;margin-bottom:.25rem;}" ++
    ".k{color:var(--dm);}" ++
    ".v{color:var(--tx);word-break:break-all;}" ++
    ".badge{display:inline-block;border:1px solid var(--bd);border-radius:999px;padding:.1rem .42rem;font-size:.58rem;margin-right:.25rem;}" ++
    ".badge.preserved{border-color:var(--p1);color:var(--p1);}" ++
    ".badge.lost{border-color:var(--rm);color:var(--rm);}" ++
    ".badge.synthetic{border-color:var(--ad);color:var(--ad);}" ++
    ".badge.delab-missing{border-color:var(--rm);color:var(--rm);}" ++
    ".badge.delab-candidate{border-color:var(--ch);color:var(--ch);}" ++
    ".badge.expr-linked{border-color:var(--ad);color:var(--ad);}" ++
    ".badge.expr-missing{border-color:var(--dm);color:var(--dm);}" ++
    ".primaryBox{border-color:#3d4f3d;background:#101812;}" ++
    ".contextBox{border-color:#303044;background:#101018;}" ++
    ".ctxDetails summary{cursor:pointer;color:var(--ac);font-family:'Syne',sans-serif;font-weight:800;font-size:.65rem;letter-spacing:.06em;margin-bottom:.35rem;}" ++
    ".box{border:1px solid var(--bd);border-radius:8px;background:#11111a;padding:.6rem .7rem;margin-top:.7rem;}" ++
    ".boxTitle{font-family:'Syne',sans-serif;color:var(--ac);font-weight:800;font-size:.65rem;letter-spacing:.06em;margin-bottom:.35rem;}" ++
    ".score{color:var(--ch);font-weight:700;}" ++
    ".warn{color:var(--rm);}" ++
    ".ok{color:var(--ad);}" ++
    ".modeNote{position:absolute;left:.8rem;top:.7rem;background:#12121acc;border:1px solid var(--bd);border-radius:7px;padding:.28rem .5rem;font-size:.54rem;color:var(--dm);z-index:30;}" ++

    "#cy{width:100%;height:100%;display:block;background:var(--bg);}" ++
    ".graphHint{position:absolute;left:.8rem;bottom:.8rem;background:#12121aaa;border:1px solid var(--bd);border-radius:7px;padding:.35rem .55rem;font-size:.54rem;color:var(--dm);z-index:30;}" ++
    ".diffBox{position:absolute;right:.8rem;bottom:.8rem;background:#12121acc;border:1px solid var(--bd);border-radius:7px;padding:.38rem .55rem;font-size:.56rem;opacity:.88;z-index:30;}" ++
    ".ds{display:flex;align-items:center;gap:.35rem;margin-bottom:.08rem;}.ds:last-child{margin-bottom:0;}" ++
    ".dc{font-family:'Syne',sans-serif;font-weight:800;font-size:.7rem;min-width:1rem;text-align:right;}" ++

    ".trace{display:grid;grid-template-rows:1fr 1fr;height:100%;}" ++
    ".traceBox{overflow:auto;border-bottom:1px solid var(--bd);}" ++
    ".traceBox:last-child{border-bottom:0;}" ++
    ".traceTitle{font-family:'Syne',sans-serif;font-weight:800;font-size:.62rem;letter-spacing:.06em;color:var(--p2);padding:.6rem .8rem .2rem;}" ++
    ".traceText{padding:.4rem .8rem .8rem;font-size:.68rem;line-height:1.75;white-space:pre-wrap;word-break:break-all;}" ++
    ".pretty{display:flex;align-items:center;justify-content:center;min-height:100%;font-size:1.45rem;font-family:'Syne',sans-serif;font-weight:800;color:var(--ac);padding:1rem;text-align:center;white-space:pre-wrap;}" ++

    ".tip{position:fixed;background:#12121a;border:1px solid var(--bd);border-radius:4px;padding:.35rem .65rem;font-size:.62rem;pointer-events:none;z-index:200;max-width:420px;word-break:break-all;opacity:0;transition:opacity .1s;}" ++
    ".tip.v{opacity:1;}" ++
    ".tk{color:var(--nd);font-weight:600;margin-bottom:.1rem;}" ++
    ".tv{color:var(--at);}" ++

    ".main.graphMode{grid-template-columns:1fr .42fr;grid-template-rows:1fr;}" ++
    ".main.graphMode .sourcePanel{display:none;}" ++
    ".main.graphMode .metaPanel{display:flex;}" ++
    ".main.graphMode .graphPanel{grid-column:1;grid-row:1;}" ++
    ".main.graphMode .tracePanel{grid-column:2;grid-row:1;}" ++

    ".main.sourceMode{grid-template-columns:1.25fr .75fr;grid-template-rows:42vh 1fr;}" ++

    "::-webkit-scrollbar{width:4px;height:4px;}" ++
    "::-webkit-scrollbar-thumb{background:var(--bd);border-radius:999px;}"

def sourceViewerBody : String :=
    "<header><h1>Lean Source Viewer v2</h1>" ++
    "<div class=\"trm\">term: <span id=\"td\"></span></div>" ++

    "<div class=\"ctrls\">" ++
      "<label class=\"ctrl\">Font <input id=\"fontCtl\" type=\"range\" min=\"8\" max=\"24\" value=\"11\"><span id=\"fontVal\">11</span></label>" ++
      "<label class=\"ctrl\">Node <input id=\"nodeCtl\" type=\"range\" min=\"16\" max=\"54\" value=\"24\"><span id=\"nodeVal\">24</span></label>" ++
      "<button class=\"btn active\" id=\"sourceModeBtn\">Source</button>" ++
      "<button class=\"btn\" id=\"graphModeBtn\">Graph</button>" ++
      "<button class=\"btn active\" id=\"focusGraphBtn\">Focus graph</button>" ++
      "<button class=\"btn\" id=\"fullGraphBtn\">Full graph</button>" ++
      "<button class=\"btn\" id=\"hygieneBtn\">Show hygiene</button>" ++
      "<button class=\"btn\" id=\"fitBtn\">Fit</button>" ++
      "<button class=\"btn\" id=\"lostBtn\">Lost only</button>" ++
      "<button class=\"btn\" id=\"corrBtn\">Trace edges</button>" ++
    "</div>" ++

    "<div class=\"leg\">" ++
      "<div class=\"li\"><div class=\"dot\" style=\"background:#89b4fa\"></div>preserved</div>" ++
      "<div class=\"li\"><div class=\"dot\" style=\"background:#f38ba8\"></div>lost</div>" ++
      "<div class=\"li\"><div class=\"dot\" style=\"background:#a6e3a1\"></div>synthetic</div>" ++
      "<div class=\"li\"><div class=\"dot\" style=\"background:#f9e2af\"></div>candidate</div>" ++
    "</div></header>" ++

    "<div class=\"main sourceMode\" id=\"main\">" ++

      "<div class=\"panel sourcePanel\">" ++
        "<div class=\"ph\"><div class=\"pn\">1</div><div class=\"pt\">Annotated Surface Source</div><div class=\"ps\">SourceInfo + leaf metadata</div></div>" ++
        "<div class=\"pb\"><div class=\"sourceWrap\">" ++
          "<div class=\"sourceIntro\">Current term:<br><span class=\"termPreview\" id=\"termPreview\"></span><br>Surface Syntax の leaf node を SourceInfo 付き token として表示します。クリックすると右側に metadata を表示します。</div>" ++
          "<div class=\"sourceLine\" id=\"sourceLine\"></div>" ++
        "</div></div>" ++
      "</div>" ++

      "<div class=\"panel metaPanel\">" ++
        "<div class=\"ph\"><div class=\"pn\">M</div><div class=\"pt\">Metadata Panel</div><div class=\"ps\">selected token</div></div>" ++
        "<div class=\"pb\"><div class=\"meta\" id=\"metaPanel\"><div class=\"metaEmpty\">トークンをクリックしてください。</div></div></div>" ++
      "</div>" ++

      "<div class=\"panel graphPanel\">" ++
        "<div class=\"ph\"><div class=\"pn\">G</div><div class=\"pt\">Mini Graph Diff</div><div class=\"ps\">focus graph / full graph</div></div>" ++
        "<div class=\"pb\">" ++
          "<div id=\"cy\"></div>" ++
          "<div class=\"modeNote\" id=\"graphModeNote\">Focus graph: select a source token</div>" ++
          "<div class=\"graphHint\">Click node: metadata / Wheel: zoom / Drag: pan</div>" ++
          "<div class=\"diffBox\">" ++
            "<div class=\"ds\"><div class=\"dc\" style=\"color:var(--rm)\" id=\"removedCnt\">0</div><div style=\"color:var(--dm)\">Surface only</div></div>" ++
            "<div class=\"ds\"><div class=\"dc\" style=\"color:var(--ad)\" id=\"addedCnt\">0</div><div style=\"color:var(--dm)\">Delab only</div></div>" ++
            "<div class=\"ds\"><div class=\"dc\" style=\"color:var(--ch)\" id=\"corrCnt\">0</div><div style=\"color:var(--dm)\">Candidates</div></div>" ++
          "</div>" ++
        "</div>" ++
      "</div>" ++

      "<div class=\"panel tracePanel\">" ++
        "<div class=\"ph\"><div class=\"pn\">T</div><div class=\"pt\">Trace</div><div class=\"ps\">Expr / Pretty</div></div>" ++
        "<div class=\"pb\"><div class=\"trace\">" ++
          "<div class=\"traceBox\"><div class=\"traceTitle\">Elaborated Expr</div><div class=\"traceText\" id=\"exprText\"></div></div>" ++
          "<div class=\"traceBox\"><div class=\"traceTitle\">Pretty Printed</div><div class=\"pretty\" id=\"prettyText\"></div></div>" ++
        "</div></div>" ++
      "</div>" ++

    "</div>" ++
    "<div class=\"tip\" id=\"tip\"><div class=\"tk\" id=\"tk\"></div><div class=\"tv\" id=\"tv\"></div></div>"

def sourceViewerJs : String :=
    "\n" ++
    "const D=window.LEAN_DATA;\n" ++
    "const termInfos=D.termInfos||[];\n" ++
    "document.getElementById('td').textContent=D.term||'';\n" ++
    "document.getElementById('termPreview').textContent=D.term||'';\n" ++
    "document.getElementById('exprText').textContent=D.phase2||'';\n" ++
    "document.getElementById('prettyText').textContent=D.phase4||'';\n" ++
    "\n" ++
    "const tip=document.getElementById('tip');\n" ++
    "function showTip(e,title,body){\n" ++
    "  document.getElementById('tk').textContent=title||'';\n" ++
    "  document.getElementById('tv').textContent=body||'';\n" ++
    "  tip.classList.add('v');moveTip(e);\n" ++
    "}\n" ++
    "function moveTip(e){tip.style.left=(e.clientX+14)+'px';tip.style.top=(e.clientY-8)+'px';}\n" ++
    "function hideTip(){tip.classList.remove('v');}\n" ++
    "function escapeHtml(s){return String(s).replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('\"','&quot;');}\n" ++
    "\n" ++
    "function labelOf(n){return n.kind || n.val || n.type || 'missing';}\n" ++
    "function short(s,n=28){s=String(s);return s.length>n?s.slice(0,n-2)+'…':s;}\n" ++
    "function labelKey(n){return (n.type||'')+'|'+(n.kind||'')+'|'+(n.val||'');}\n" ++
    "function cmpKey(n,p=''){return p+'/'+(n.kind||n.type)+(n.val?':'+n.val:'');}\n" ++
    "function rangeText(t){return (t.start==null||t.end==null)?'range: null':'range: '+t.start+'..'+t.end;}\n" ++
    "\n" ++
    "function collectPathKeys(n,p='',set=new Set()){\n" ++
    "  const k=cmpKey(n,p);set.add(k);\n" ++
    "  if(n.children)n.children.forEach((c,i)=>collectPathKeys(c,k+'['+i+']',set));\n" ++
    "  return set;\n" ++
    "}\n" ++
    "function pathDistance(a,b){\n" ++
    "  const xs=String(a).split('_'); const ys=String(b).split('_');\n" ++
    "  const n=Math.min(xs.length,ys.length); let same=0;\n" ++
    "  for(let i=0;i<n;i++){ if(xs[i]===ys[i]) same++; else break; }\n" ++
    "  return Math.max(xs.length,ys.length)-same;\n" ++
    "}\n" ++
    "function scoreCandidate(s,d){\n" ++
    "  let score=0;\n" ++
    "  if(s.type===d.type)score+=2;\n" ++
    "  if(s.kind && s.kind===d.kind)score+=3;\n" ++
    "  if(s.val && s.val===d.val)score+=4;\n" ++
    "  if(s.label===d.label)score+=2;\n" ++
    "  if(s.occ===d.occ)score+=2;\n" ++
    "  if(s.parentKey && s.parentKey===d.parentKey)score+=2;\n" ++
    "  if(s.start!=null && d.start!=null && s.start===d.start)score+=1;\n" ++
    "  score-=Math.abs((s.depth||0)-(d.depth||0))*0.5;\n" ++
    "  score-=pathDistance(s.path,d.path)*0.2;\n" ++
    "  return Math.round(score*10)/10;\n" ++
    "}\n" ++
    "function collectLeaves(root,phase,pathKeysOther){\n" ++
    "  let out=[]; const occurrenceCounter={};\n" ++
    "  function walk(n,path,recursivePath,depth,parentKey){\n" ++
    "    const isLeaf=!n.children||n.children.length===0;\n" ++
    "    const k=cmpKey(n,recursivePath);\n" ++
    "    const myKey=labelKey(n);\n" ++
    "    if(isLeaf){\n" ++
    "      const existsOther=pathKeysOther.has(k);\n" ++
    "      let status='preserved';\n" ++
    "      if(phase==='surface' && !existsOther) status='lost';\n" ++
    "      if(phase==='delab' && !existsOther) status='synthetic';\n" ++
    "      const key=labelKey(n);\n" ++
    "      const occ=occurrenceCounter[key]||0;\n" ++
    "      occurrenceCounter[key]=occ+1;\n" ++
    "      out.push({label:labelOf(n),shortLabel:short(labelOf(n),24),phase,type:n.type||'',kind:n.kind||'',val:n.val||'',path,recursivePath,key,occ,status,start:n.start,end:n.end,depth,parentKey:parentKey||''});\n" ++
    "    }\n" ++
    "    if(n.children)n.children.forEach((c,i)=>walk(c,path+'_'+i,k+'['+i+']',depth+1,myKey));\n" ++
    "  }\n" ++
    "  walk(root,'0','',0,''); return out;\n" ++
    "}\n" ++
    "const sKeys=collectPathKeys(D.tree1);\n" ++
    "const dKeys=collectPathKeys(D.tree3);\n" ++
    "const surfaceLeaves=collectLeaves(D.tree1,'surface',dKeys);\n" ++
    "const delabLeaves=collectLeaves(D.tree3,'delab',sKeys);\n" ++
    "\n" ++
    "let showHygiene=false;\n" ++
    "let currentGraphKind='focus';\n" ++
    "let selectedToken=null;\n" ++
    "let corrVisible=true;\n" ++
    "let lostOnly=false;\n" ++
    "\n" ++
    "function isHiddenSourceToken(t){\n" ++
    "  return t.label==='[anonymous]' || t.parentKey==='node|hygieneInfo|' || t.key==='ident||[anonymous]' || String(t.kind||'').includes('hygieneInfo');\n" ++
    "}\n" ++
    "function visibleSurfaceLeaves(){return showHygiene?surfaceLeaves:surfaceLeaves.filter(t=>!isHiddenSourceToken(t));}\n" ++
    "function termInfosForToken(t){\n" ++
    "  return termInfos.filter(info=>info.start!=null && info.end!=null && t.start!=null && t.end!=null && info.start<=t.start && t.end<=info.end)\n" ++
    "    .sort((a,b)=>((a.end-a.start)-(b.end-b.start)));\n" ++
    "}\n" ++
    "function primaryInfoForToken(t){const infos=termInfosForToken(t);return infos.length>0?infos[0]:null;}\n" ++
    "function candidatesForToken(t){\n" ++
    "  const pool=delabLeaves.filter(d=>d.label===t.label || d.key===t.key);\n" ++
    "  return pool.map(d=>Object.assign({},d,{score:scoreCandidate(t,d)})).sort((a,b)=>b.score-a.score).slice(0,5);\n" ++
    "}\n" ++
    "function delabStatusLabel(t,cands){\n" ++
    "  if(t.status==='lost') return cands.length>0?'delab-candidate':'delab-missing';\n" ++
    "  if(t.status==='synthetic') return 'delab-synthetic';\n" ++
    "  return 'delab-preserved';\n" ++
    "}\n" ++
    "function exprStatusLabel(infos){return infos.length>0?'expr-linked':'expr-missing';}\n" ++
    "function interpretationForToken(t,cands,infos){\n" ++
    "  const primary=infos.length>0?infos[0]:null;\n" ++
    "  const delabStatus=delabStatusLabel(t,cands);\n" ++
    "  const exprStatus=exprStatusLabel(infos);\n" ++
    "  let parts=[];\n" ++
    "  if(exprStatus==='expr-linked'){\n" ++
    "    parts.push('この token は InfoTree 上の TermInfo に接続されています。最も近い対応は range='+primary.start+'..'+primary.end+' の '+(primary.syntax||'')+' で、expr='+(primary.expr||'')+' / type='+(primary.type||'')+' です。');\n" ++
    "  }else{\n" ++
    "    parts.push('この token の SourceInfo range に対応する TermInfo は見つかっていません。単なる構文記号、hygiene 情報、または elaboration で直接 Expr に対応しない構文要素の可能性があります。');\n" ++
    "  }\n" ++
    "  if(delabStatus==='delab-missing'){\n" ++
    "    parts.push('一方で、Delaborated Syntax 側には同名候補が見つかっていません。これは Delab に対しては surface-only な情報で、括弧・記法上の包み・hygiene などの消失候補です。');\n" ++
    "  }else if(delabStatus==='delab-candidate'){\n" ++
    "    parts.push('Delaborated 側に似た候補はありますが、Delab 候補では SourceInfo が null になりやすいです。元 token が保存されたというより、Expr から似た表示が再構成された可能性があります。');\n" ++
    "  }else{\n" ++
    "    parts.push('Delaborated 側との leaf-level candidate もあります。ただし、これは label / score に基づく候補であり、意味的対応の証明ではありません。');\n" ++
    "  }\n" ++
    "  return parts.join(' ');\n" ++
    "}\n" ++
    "function tokenClass(t){return 'tok '+(t.status==='lost'?'lost':t.status==='synthetic'?'synthetic':'preserved');}\n" ++
    "function renderSource(){\n" ++
    "  const el=document.getElementById('sourceLine'); el.innerHTML='';\n" ++
    "  visibleSurfaceLeaves().forEach(t=>{\n" ++
    "    const span=document.createElement('span');\n" ++
    "    span.className=tokenClass(t); span.textContent=t.shortLabel; span.dataset.path=t.path; span.title=rangeText(t);\n" ++
    "    span.addEventListener('click',()=>selectToken(t));\n" ++
    "    span.addEventListener('mouseover',e=>showTip(e,t.label,'status='+t.status+' / '+rangeText(t)+' / kind='+(t.kind||'')+' / type='+(t.type||'')+' / occ='+String(t.occ)));\n" ++
    "    span.addEventListener('mousemove',moveTip); span.addEventListener('mouseout',hideTip);\n" ++
    "    el.appendChild(span);\n" ++
    "  });\n" ++
    "}\n" ++
    "function renderInfoDetails(info,prefix){\n" ++
    "  let h='';\n" ++
    "  h+='<div class=\"kv\"><div class=\"k\">'+prefix+' range</div><div class=\"v\">'+escapeHtml(String(info.start))+'..'+escapeHtml(String(info.end))+'</div>';\n" ++
    "  h+='<div class=\"k\">syntax</div><div class=\"v\">'+escapeHtml(info.syntax||'')+'</div>';\n" ++
    "  h+='<div class=\"k\">elaborator</div><div class=\"v\">'+escapeHtml(info.elaborator||'')+'</div>';\n" ++
    "  h+='<div class=\"k\">expr</div><div class=\"v\">'+escapeHtml(info.expr||'')+'</div>';\n" ++
    "  h+='<div class=\"k\">type</div><div class=\"v\">'+escapeHtml(info.type||'')+'</div>';\n" ++
    "  h+='<div class=\"k\">expected</div><div class=\"v\">'+escapeHtml(info.expected||'')+'</div></div>';\n" ++
    "  return h;\n" ++
    "}\n" ++
    "function metaHtml(t){\n" ++
    "  const cands=candidatesForToken(t); const infos=termInfosForToken(t);\n" ++
    "  const delabStatus=delabStatusLabel(t,cands); const exprStatus=exprStatusLabel(infos); const primary=infos.length>0?infos[0]:null;\n" ++
    "  let h='';\n" ++
    "  h+='<span class=\"badge '+(delabStatus==='delab-missing'?'delab-missing':'delab-candidate')+'\">Delab: '+escapeHtml(delabStatus)+'</span>';\n" ++
    "  h+='<span class=\"badge '+(exprStatus==='expr-linked'?'expr-linked':'expr-missing')+'\">Expr: '+escapeHtml(exprStatus)+'</span>';\n" ++
    "  h+='<span class=\"rangeBadge\">'+escapeHtml(rangeText(t))+'</span>';\n" ++
    "  h+='<div class=\"box\"><div class=\"boxTitle\">Surface token</div>';\n" ++
    "  h+='<div class=\"kv\"><div class=\"k\">label</div><div class=\"v\">'+escapeHtml(t.label)+'</div>';\n" ++
    "  h+='<div class=\"k\">kind</div><div class=\"v\">'+escapeHtml(t.kind||'')+'</div>';\n" ++
    "  h+='<div class=\"k\">type</div><div class=\"v\">'+escapeHtml(t.type||'')+'</div>';\n" ++
    "  h+='<div class=\"k\">value</div><div class=\"v\">'+escapeHtml(t.val||'')+'</div>';\n" ++
    "  h+='<div class=\"k\">path</div><div class=\"v\">'+escapeHtml(t.path)+'</div>';\n" ++
    "  h+='<div class=\"k\">occurrence</div><div class=\"v\">'+String(t.occ)+'</div>';\n" ++
    "  h+='<div class=\"k\">depth</div><div class=\"v\">'+String(t.depth)+'</div>';\n" ++
    "  h+='<div class=\"k\">SourceInfo</div><div class=\"v\">start='+escapeHtml(String(t.start))+', end='+escapeHtml(String(t.end))+'</div></div></div>';\n" ++
    "  h+='<div class=\"box primaryBox\"><div class=\"boxTitle\">Primary Expr relation</div>';\n" ++
    "  if(primary==null){h+='<div class=\"v\"><span class=\"warn\">No direct TermInfo found.</span><br>この token の SourceInfo range を含む TermInfo は見つかりませんでした。</div>';}\n" ++
    "  else{h+=renderInfoDetails(primary,'primary');}\n" ++
    "  h+='</div>';\n" ++
    "  const parents=infos.slice(1,4);\n" ++
    "  h+='<div class=\"box contextBox\"><div class=\"boxTitle\">Parent Expr contexts (top 3)</div>';\n" ++
    "  if(parents.length===0){h+='<div class=\"v\">No parent TermInfo contexts.</div>';}\n" ++
    "  else{parents.forEach((info,i)=>{h+=renderInfoDetails(info,'context '+(i+1));});}\n" ++
    "  h+='</div>';\n" ++
    "  h+='<div class=\"box\"><div class=\"boxTitle\">Delaborated candidates with score</div>';\n" ++
    "  if(cands.length===0){h+='<div class=\"v\">No candidate found.</div>';}\n" ++
    "  else{cands.forEach((c,i)=>{h+='<div class=\"kv\"><div class=\"k\">candidate '+(i+1)+'</div><div class=\"v\">'+escapeHtml(c.label)+' / '+escapeHtml(c.path)+' / occ='+String(c.occ)+' / <span class=\"score\">score='+String(c.score)+'</span> / range='+escapeHtml(String(c.start))+'..'+escapeHtml(String(c.end))+'</div></div>';});}\n" ++
    "  h+='</div>';\n" ++
    "  h+='<div class=\"box\"><div class=\"boxTitle\">Interpretation</div>';\n" ++
    "  h+='<div class=\"v\">'+escapeHtml(interpretationForToken(t,cands,infos))+'</div>';\n" ++
    "  h+='</div>';\n" ++
    "  return h;\n" ++
    "}\n" ++
    "\n" ++
    "function flattenGraph(root,prefix,phase,baseX,pathKeysOther){\n" ++
    "  let nodes=[];let edges=[];let buckets={};let order=0;\n" ++
    "  const depthGap=108;const rowGap=48;const topY=70;\n" ++
    "  function walk(n,depth,parentId,path,recursivePath,parentKey){\n" ++
    "    const id=prefix+path; const k=cmpKey(n,recursivePath); const existsOther=pathKeysOther.has(k);\n" ++
    "    const key=labelKey(n); const fullLabel=labelOf(n);\n" ++
    "    const hidden=(!showHygiene && (fullLabel==='[anonymous]' || key==='ident||[anonymous]' || key==='node|hygieneInfo|' || String(key).includes('hygieneInfo')));\n" ++
    "    let diff='same'; if(phase==='surface' && !existsOther) diff='removed'; if(phase==='delab' && !existsOther) diff='added';\n" ++
    "    const x=baseX+depth*depthGap; const y=topY+order*rowGap; order++;\n" ++
    "    nodes.push({data:{id,label:short(fullLabel,20),fullLabel,phase,type:n.type||'',kind:n.kind||'',val:n.val||'',diff,path,key,start:n.start,end:n.end,depth,parentKey:parentKey||'',hiddenHygiene:hidden},position:{x,y}});\n" ++
    "    if(!buckets[key])buckets[key]=[]; buckets[key].push(id);\n" ++
    "    if(parentId)edges.push({data:{id:'child_'+parentId+'_'+id,source:parentId,target:id,kind:'child',phase}});\n" ++
    "    if(n.children)n.children.forEach((c,i)=>walk(c,depth+1,id,path+'_'+i,k+'['+i+']',key));\n" ++
    "  }\n" ++
    "  walk(root,0,null,'0','',''); return {nodes,edges,buckets};\n" ++
    "}\n" ++
    "function cyStyles(){return [\n" ++
    "  {selector:'node',style:{'label':'data(label)','font-family':'JetBrains Mono','font-size':'var(--node-font)','color':'#cdd6f4','text-valign':'center','text-wrap':'wrap','text-max-width':'120px','text-background-color':'#0a0a0f','text-background-opacity':0.75,'text-background-padding':'2px','width':'var(--node-size)','height':'var(--node-size)','border-width':2,'background-color':'#1a1a30','border-color':'#cba6f7'}},\n" ++
    "  {selector:'node[phase=\"surface\"]',style:{'background-color':'#0a1a30','border-color':'#89b4fa','text-halign':'right','text-margin-x':-8}},\n" ++
    "  {selector:'node[phase=\"info\"]',style:{'background-color':'#1d1a08','border-color':'#f9e2af','shape':'hexagon','text-halign':'center'}},\n" ++
    "  {selector:'node[role=\"primary\"]',style:{'border-width':5,'border-color':'#f9e2af'}},\n" ++
    "  {selector:'node[role=\"context\"]',style:{'border-style':'dashed','opacity':0.86}},\n" ++
    "  {selector:'node[phase=\"delab\"]',style:{'background-color':'#0a2518','border-color':'#a6e3a1','text-halign':'left','text-margin-x':8}},\n" ++
    "  {selector:'node[diff=\"removed\"]',style:{'background-color':'#301018','border-color':'#f38ba8','border-width':4}},\n" ++
    "  {selector:'node[diff=\"added\"]',style:{'background-color':'#0e2d18','border-color':'#a6e3a1','border-width':4}},\n" ++
    "  {selector:'node[type=\"atom\"]',style:{'shape':'round-rectangle'}},\n" ++
    "  {selector:'node[type=\"ident\"]',style:{'shape':'diamond'}},\n" ++
    "  {selector:'edge[kind=\"child\"]',style:{'width':1,'line-color':'#1e1e2e','target-arrow-color':'#1e1e2e','target-arrow-shape':'triangle','curve-style':'bezier','opacity':0.42}},\n" ++
    "  {selector:'edge[kind=\"s2i\"]',style:{'width':2.1,'line-color':'#89b4fa','target-arrow-color':'#f9e2af','target-arrow-shape':'vee','curve-style':'bezier','line-style':'solid','opacity':0.75,'label':'data(label)','font-size':'8px','color':'#89b4fa','text-background-color':'#0a0a0f','text-background-opacity':0.7}},\n" ++
    "  {selector:'edge[kind=\"ctx\"]',style:{'width':1.2,'line-color':'#f9e2af','target-arrow-color':'#f9e2af','target-arrow-shape':'vee','curve-style':'bezier','line-style':'dotted','opacity':0.5,'label':'data(label)','font-size':'8px','color':'#f9e2af','text-background-color':'#0a0a0f','text-background-opacity':0.7}},\n" ++
    "  {selector:'edge[kind=\"i2d\"]',style:{'width':1.7,'line-color':'#f9e2af','target-arrow-color':'#a6e3a1','target-arrow-shape':'vee','curve-style':'bezier','line-style':'dashed','opacity':0.52,'label':'data(label)','font-size':'8px','color':'#f9e2af','text-background-color':'#0a0a0f','text-background-opacity':0.7}},\n" ++
    "  {selector:'.faded',style:{'opacity':0.10}},\n" ++
    "  {selector:'.selectedFocus',style:{'border-width':6,'border-color':'#f5c2e7'}}\n" ++
    "];}\n" ++
    "function renderInfoNodeHtml(d){\n" ++
    "  let h='<div class=\"box primaryBox\"><div class=\"boxTitle\">TermInfo / Expr node</div>';\n" ++
    "  h+='<div class=\"kv\"><div class=\"k\">range</div><div class=\"v\">'+escapeHtml(String(d.start))+'..'+escapeHtml(String(d.end))+'</div>';\n" ++
    "  h+='<div class=\"k\">syntax</div><div class=\"v\">'+escapeHtml(d.syntax||'')+'</div>';\n" ++
    "  h+='<div class=\"k\">elaborator</div><div class=\"v\">'+escapeHtml(d.elaborator||'')+'</div>';\n" ++
    "  h+='<div class=\"k\">expr</div><div class=\"v\">'+escapeHtml(d.expr||'')+'</div>';\n" ++
    "  h+='<div class=\"k\">type</div><div class=\"v\">'+escapeHtml(d.type||'')+'</div>';\n" ++
    "  h+='<div class=\"k\">expected</div><div class=\"v\">'+escapeHtml(d.expected||'')+'</div></div></div>';\n" ++
    "  h+='<div class=\"box\"><div class=\"boxTitle\">Interpretation</div><div class=\"v\">この中央ノードは InfoTree から得た TermInfo です。左の Surface Syntax range が elaboration によりこの Expr/type に対応し、右の Delaborated Syntax 候補へ接続します。</div></div>';\n" ++
    "  return h;\n" ++
    "}\n" ++
    "function setGraphElements(elements,note,padding=55){\n" ++
    "  const noteEl=document.getElementById('graphModeNote'); if(noteEl)noteEl.textContent=note;\n" ++
    "  const container=document.getElementById('cy');\n" ++
    "  if(!container){return;}\n" ++
    "  try{\n" ++
    "    if(window.cyInstance && typeof window.cyInstance.destroy === 'function'){window.cyInstance.destroy();}\n" ++
    "    window.cyInstance=null;\n" ++
    "    container.innerHTML='';\n" ++
    "    window.cyInstance=cytoscape({container:container,elements:elements,wheelSensitivity:0.18,layout:{name:'preset'},style:cyStyles()});\n" ++
    "    bindCyEvents();\n" ++
    "    setTimeout(()=>{if(window.cyInstance)window.cyInstance.fit(undefined,padding);},140);\n" ++
    "    if(!corrVisible && window.cyInstance)window.cyInstance.edges('[kind=\"s2i\"],[kind=\"i2d\"],[kind=\"ctx\"]').style('display','none');\n" ++
    "  }catch(e){\n" ++
    "    console.error(e);\n" ++
    "    if(noteEl)noteEl.textContent='Graph render error: '+e.message;\n" ++
    "  }\n" ++
    "}\n" ++
    "function infoNodeData(info,id,x,y,role){\n" ++
    "  return {data:{id,label:short((role==='primary'?'Primary ':'Context ')+(info.expr||info.syntax||'TermInfo')+' : '+(info.type||'?'),30),fullLabel:info.expr||info.syntax||'TermInfo',phase:'info',role,kind:info.kind||'TermInfo',syntax:info.syntax||'',elaborator:info.elaborator||'',expr:info.expr||'',type:info.type||'',expected:info.expected||'',start:info.start,end:info.end,path:id,diff:'info'},position:{x,y}};\n" ++
    "}\n" ++
    "function buildFocusGraph(t){\n" ++
    "  const infos=termInfosForToken(t); const primary=infos[0]||null; const parents=infos.slice(1,3); const cands=candidatesForToken(t).slice(0,1);\n" ++
    "  let nodes=[]; let edges=[];\n" ++
    "  nodes.push({data:{id:'fs',label:short(t.label,18),fullLabel:t.label,phase:'surface',type:t.type||'',kind:t.kind||'',val:t.val||'',diff:t.status==='lost'?'removed':'same',path:t.path,start:t.start,end:t.end},position:{x:120,y:220}});\n" ++
    "  if(primary){\n" ++
    "    nodes.push(infoNodeData(primary,'fi0',430,180,'primary'));\n" ++
    "    edges.push({data:{id:'fs_fi0',source:'fs',target:'fi0',kind:'s2i',label:'elab'}});\n" ++
    "    parents.forEach((p,i)=>{const id='fc'+i; nodes.push(infoNodeData(p,id,430,300+i*92,'context')); edges.push({data:{id:'fi0_'+id,source:'fi0',target:id,kind:'ctx',label:'ctx'}});});\n" ++
    "    cands.forEach((c,i)=>{const id='fd'+i; nodes.push({data:{id,label:short(c.label,18),fullLabel:c.label,phase:'delab',type:c.type||'',kind:c.kind||'',val:c.val||'',diff:c.status==='synthetic'?'added':'same',path:c.path,start:c.start,end:c.end,score:c.score},position:{x:760,y:180+i*100}}); edges.push({data:{id:'fi0_'+id,source:'fi0',target:id,kind:'i2d',label:String(c.score)}});});\n" ++
    "  }\n" ++
    "  return {elements:[...nodes,...edges],note:'Focus graph: selected token = '+t.label};\n" ++
    "}\n" ++
    "function buildFullGraph(){\n" ++
    "  const sg=flattenGraph(D.tree1,'s','surface',80,dKeys); const dg=flattenGraph(D.tree3,'d','delab',920,sKeys);\n" ++
    "  const visible=visibleSurfaceLeaves();\n" ++
    "  const infoKeyOf=info=>String(info.start)+'..'+String(info.end)+'|'+(info.syntax||'')+'|'+(info.expr||'')+'|'+(info.type||'');\n" ++
    "  const primaryInfoKeys=new Set(); visible.forEach(t=>{const pi=primaryInfoForToken(t); if(pi)primaryInfoKeys.add(infoKeyOf(pi));});\n" ++
    "  const graphInfos=termInfos.filter(info=>primaryInfoKeys.has(infoKeyOf(info))).sort((a,b)=>{const aw=(a.end??999999)-(a.start??0);const bw=(b.end??999999)-(b.start??0);if(a.start!==b.start)return (a.start??999999)-(b.start??999999);return aw-bw;});\n" ++
    "  const infoIdByKey={};\n" ++
    "  const infoNodes=graphInfos.map((info,i)=>{const id='i'+i; infoIdByKey[infoKeyOf(info)]=id; return infoNodeData(info,id,500,70+i*58,'primary');});\n" ++
    "  const delabNodeById={}; dg.nodes.forEach(n=>delabNodeById[n.data.id]=n.data);\n" ++
    "  let traceEdges=[];let traceN=0;\n" ++
    "  visible.forEach(s=>{const pi=primaryInfoForToken(s); if(pi){const infoId=infoIdByKey[infoKeyOf(pi)]; if(infoId){traceEdges.push({data:{id:'s2i_'+traceN,source:'s'+s.path,target:infoId,kind:'s2i',label:'elab'}});traceN++;} const cands=candidatesForToken(s).slice(0,2); cands.forEach(c=>{const targetId='d'+c.path; if(infoId && delabNodeById[targetId]){traceEdges.push({data:{id:'i2d_'+traceN,source:infoId,target:targetId,kind:'i2d',score:c.score,label:String(c.score)}});traceN++;}});}});\n" ++
    "  let elements=[...sg.nodes,...infoNodes,...dg.nodes,...sg.edges,...dg.edges,...traceEdges];\n" ++
    "  if(!showHygiene){const hiddenIds=new Set(elements.filter(e=>e.data&&e.data.hiddenHygiene).map(e=>e.data.id)); elements=elements.filter(e=>{if(!e.data)return true; if(e.data.hiddenHygiene)return false; if(e.data.source&&hiddenIds.has(e.data.source))return false; if(e.data.target&&hiddenIds.has(e.data.target))return false; return true;});}\n" ++
    "  document.getElementById('removedCnt').textContent=sg.nodes.filter(n=>n.data.diff==='removed').length;\n" ++
    "  document.getElementById('addedCnt').textContent=dg.nodes.filter(n=>n.data.diff==='added').length;\n" ++
    "  document.getElementById('corrCnt').textContent=traceEdges.length;\n" ++
    "  return {elements,note:'Full graph: Surface / TermInfo / Delab'};\n" ++
    "}\n" ++
    "function renderGraph(){\n" ++
    "  if(currentGraphKind==='full'){\n" ++
    "    const g=buildFullGraph(); setGraphElements(g.elements,g.note,45);\n" ++
    "  }else{\n" ++
    "    const visible=visibleSurfaceLeaves();\n" ++
    "    if(!selectedToken || (!showHygiene && isHiddenSourceToken(selectedToken))){selectedToken=visible.find(t=>t.start!=null)||visible[0]||surfaceLeaves[0]||null;}\n" ++
    "    if(selectedToken){const g=buildFocusGraph(selectedToken); setGraphElements(g.elements,g.note,80);}\n" ++
    "    else{setGraphElements([], 'Focus graph: no selectable source token', 80);}\n" ++
    "  }\n" ++
    "}\n" ++
    "function bindCyEvents(){\n" ++
    "  const cy=window.cyInstance; if(!cy)return;\n" ++
    "  cy.on('mouseover','node',evt=>{const d=evt.target.data(); showTip(evt.originalEvent,d.fullLabel||d.label,'phase='+d.phase+' / range='+d.start+'..'+d.end+' / path='+(d.path||''));});\n" ++
    "  cy.on('mousemove','node',evt=>moveTip(evt.originalEvent)); cy.on('mouseout','node',hideTip);\n" ++
    "  cy.on('tap','node',evt=>{\n" ++
    "    const d=evt.target.data();\n" ++
    "    if(d.phase==='surface'){\n" ++
    "      const leaf=surfaceLeaves.find(t=>t.path===d.path);\n" ++
    "      if(leaf)selectToken(leaf);\n" ++
    "    }else if(d.phase==='info'){\n" ++
    "      document.getElementById('metaPanel').innerHTML=renderInfoNodeHtml(d);\n" ++
    "      cy.elements().removeClass('faded selectedFocus'); const n=evt.target; const connected=n.connectedEdges(); n.addClass('selectedFocus');\n" ++
    "      cy.elements().not(n).not(connected).not(connected.connectedNodes()).addClass('faded');\n" ++
    "    }else{\n" ++
    "      document.getElementById('metaPanel').innerHTML='<div class=\"box\"><div class=\"boxTitle\">Delaborated node</div><div class=\"kv\"><div class=\"k\">label</div><div class=\"v\">'+escapeHtml(d.fullLabel||d.label)+'</div><div class=\"k\">kind</div><div class=\"v\">'+escapeHtml(d.kind||'')+'</div><div class=\"k\">type</div><div class=\"v\">'+escapeHtml(d.type||'')+'</div><div class=\"k\">diff</div><div class=\"v\">'+escapeHtml(d.diff||'')+'</div><div class=\"k\">SourceInfo</div><div class=\"v\">start='+escapeHtml(String(d.start))+', end='+escapeHtml(String(d.end))+'</div><div class=\"k\">path</div><div class=\"v\">'+escapeHtml(d.path||'')+'</div></div><div class=\"box\"><div class=\"boxTitle\">Interpretation</div><div class=\"v\">このノードは Delaborated Syntax 側のノードです。Delaborated 側では SourceInfo が null になりやすく、これは Expr から再構成された構文が元ソース範囲を直接保持しないことを示す観察点です。</div></div></div>';\n" ++
    "    }\n" ++
    "  });\n" ++
    "  cy.on('tap',evt=>{if(evt.target===cy){cy.elements().removeClass('faded selectedFocus');document.querySelectorAll('.tok').forEach(x=>x.classList.remove('selected'));}});\n" ++
    "}\n" ++
    "function selectToken(t){\n" ++
    "  selectedToken=t;\n" ++
    "  document.querySelectorAll('.tok').forEach(x=>x.classList.remove('selected'));\n" ++
    "  const tok=document.querySelector('.tok[data-path=\"'+t.path+'\"]'); if(tok)tok.classList.add('selected');\n" ++
    "  document.getElementById('metaPanel').innerHTML=metaHtml(t);\n" ++
    "  if(currentGraphKind==='focus')renderGraph();\n" ++
    "  else if(window.cyInstance){const cy=window.cyInstance; cy.elements().removeClass('faded selectedFocus'); const node=cy.$('#s'+t.path); if(node.length){const connected=node.connectedEdges(); node.addClass('selectedFocus'); cy.elements().not(node).not(connected).not(connected.connectedNodes()).addClass('faded');}}\n" ++
    "}\n" ++
    "\n" ++
    "renderSource();\n" ++
    "if(visibleSurfaceLeaves().length>0) selectedToken=visibleSurfaceLeaves().find(t=>t.start!=null)||visibleSurfaceLeaves()[0];\n" ++
    "setTimeout(()=>{if(selectedToken)selectToken(selectedToken);else renderGraph();},0);\n" ++
    "\n" ++
    "function applySizes(){\n" ++
    "  const f=document.getElementById('fontCtl').value; const ns=document.getElementById('nodeCtl').value;\n" ++
    "  document.documentElement.style.setProperty('--node-font',f+'px');\n" ++
    "  document.documentElement.style.setProperty('--node-size',ns+'px');\n" ++
    "  document.documentElement.style.setProperty('--source-font',(Number(f)/10+0.3)+'rem');\n" ++
    "  document.getElementById('fontVal').textContent=f; document.getElementById('nodeVal').textContent=ns;\n" ++
    "  if(window.cyInstance)window.cyInstance.style().update();\n" ++
    "}\n" ++
    "document.getElementById('fontCtl').addEventListener('input',applySizes);\n" ++
    "document.getElementById('nodeCtl').addEventListener('input',applySizes);\n" ++
    "document.getElementById('fitBtn').addEventListener('click',()=>window.cyInstance&&window.cyInstance.fit(undefined,currentGraphKind==='focus'?80:45));\n" ++
    "document.getElementById('lostBtn').addEventListener('click',()=>{\n" ++
    "  lostOnly=!lostOnly;\n" ++
    "  document.querySelectorAll('.tok').forEach(el=>{if(lostOnly && !el.classList.contains('lost'))el.classList.add('dim');else el.classList.remove('dim');});\n" ++
    "  if(window.cyInstance){const cy=window.cyInstance; cy.elements().removeClass('faded'); if(lostOnly){cy.nodes('[diff=\"same\"]').addClass('faded'); cy.edges('[kind=\"child\"]').addClass('faded');}}\n" ++
    "});\n" ++
    "document.getElementById('corrBtn').addEventListener('click',()=>{\n" ++
    "  corrVisible=!corrVisible;\n" ++
    "  if(window.cyInstance)window.cyInstance.edges('[kind=\"s2i\"],[kind=\"i2d\"],[kind=\"ctx\"]').style('display',corrVisible?'element':'none');\n" ++
    "});\n" ++
    "function setGraphKind(kind){\n" ++
    "  currentGraphKind=kind;\n" ++
    "  document.getElementById('focusGraphBtn').classList.toggle('active',kind==='focus');\n" ++
    "  document.getElementById('fullGraphBtn').classList.toggle('active',kind==='full');\n" ++
    "  renderGraph();\n" ++
    "}\n" ++
    "document.getElementById('focusGraphBtn').addEventListener('click',()=>setGraphKind('focus'));\n" ++
    "document.getElementById('fullGraphBtn').addEventListener('click',()=>setGraphKind('full'));\n" ++
    "document.getElementById('hygieneBtn').addEventListener('click',()=>{\n" ++
    "  showHygiene=!showHygiene;\n" ++
    "  document.getElementById('hygieneBtn').classList.toggle('active',showHygiene);\n" ++
    "  document.getElementById('hygieneBtn').textContent=showHygiene?'Hide hygiene':'Show hygiene';\n" ++
    "  renderSource();\n" ++
    "  if(selectedToken && !showHygiene && isHiddenSourceToken(selectedToken)){selectedToken=visibleSurfaceLeaves()[0]||null;}\n" ++
    "  renderGraph();\n" ++
    "});\n" ++
    "function setMode(mode){\n" ++
    "  const main=document.getElementById('main'); const sourceBtn=document.getElementById('sourceModeBtn'); const graphBtn=document.getElementById('graphModeBtn');\n" ++
    "  if(mode==='graph'){\n" ++
    "    main.classList.remove('sourceMode');main.classList.add('graphMode'); sourceBtn.classList.remove('active');graphBtn.classList.add('active');\n" ++
    "  }else{\n" ++
    "    main.classList.remove('graphMode');main.classList.add('sourceMode'); graphBtn.classList.remove('active');sourceBtn.classList.add('active');\n" ++
    "  }\n" ++
    "  setTimeout(()=>window.cyInstance&&window.cyInstance.fit(undefined,currentGraphKind==='focus'?80:45),80);\n" ++
    "}\n" ++
    "document.getElementById('sourceModeBtn').addEventListener('click',()=>setMode('source'));\n" ++
    "document.getElementById('graphModeBtn').addEventListener('click',()=>setMode('graph'));\n"

def renderSourceViewerHtml (data : String) : String :=
  "<!DOCTYPE html><html lang=\"ja\"><head><meta charset=\"UTF-8\"><title>Lean Source Viewer v2</title>" ++
  "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.28.1/cytoscape.min.js\"></script>" ++
  "<link href=\"https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&family=Syne:wght@700;800&display=swap\" rel=\"stylesheet\">" ++
  "<style>" ++ sourceViewerCss ++ "</style></head><body>" ++
  sourceViewerBody ++
  "<script>" ++ data ++ sourceViewerJs ++ "</script>" ++
  "</body></html>"

def writeSourceViewerHtmlFile
    (data : String)
    (outPath : String := "lean_source_viewer_v2.html") : IO Unit := do
  IO.FS.writeFile outPath (renderSourceViewerHtml data)

end LeanFormatterLab
