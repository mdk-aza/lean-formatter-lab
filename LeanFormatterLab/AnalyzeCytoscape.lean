import Lean
import Lean.Widget.UserWidget

namespace LeanFormatterLab

open Lean Meta Elab Term

-- ===== JSON変換 =====

private def escapeJson (s : String) : String :=
  s.foldl (fun acc c =>
    acc ++ match c with
      | '"'  => "\\\""
      | '\\' => "\\\\"
      | '\n' => "\\n"
      | '\r' => "\\r"
      | '\t' => "\\t"
      | c    => String.singleton c
  ) ""

partial def syntaxToJson : Syntax → String
  | .node _ kind args =>
      let kids := args.toList.map syntaxToJson |>.intersperse "," |>.foldl (· ++ ·) ""
      s!"\{\"type\":\"node\",\"kind\":\"{escapeJson kind.toString}\",\"children\":[{kids}]}"
  | .atom _ val =>
      s!"\{\"type\":\"atom\",\"val\":\"{escapeJson val}\"}"
  | .ident _ _ val _ =>
      s!"\{\"type\":\"ident\",\"val\":\"{escapeJson val.toString}\"}"
  | _ =>
      "{\"type\":\"missing\"}"

-- ===== HTML生成 =====

def writeAnalysisHtml
    (termStr phase2Str phase4Str tree1Json tree3Json : String)
    (outPath : String := "lean_graph_diff.html") : IO Unit := do

  let data :=
    "window.LEAN_DATA={" ++
    s!"term:\"{escapeJson termStr}\"," ++
    s!"phase2:\"{escapeJson phase2Str}\"," ++
    s!"phase4:\"{escapeJson phase4Str}\"," ++
    s!"tree1:{tree1Json}," ++
    s!"tree3:{tree3Json}" ++
    "};"

  let css :=
    ":root{--bg:#0a0a0f;--panel:#0d0d14;--bd:#1e1e2e;--tx:#cdd6f4;--dm:#585b70;--nd:#cba6f7;--at:#fab387;--id:#89dceb;--ad:#a6e3a1;--rm:#f38ba8;--ch:#f9e2af;--ac:#f5c2e7;--p1:#89b4fa;--p2:#f9e2af;--p3:#a6e3a1;--p4:#f5c2e7;--node-font:13px;--node-size:28px;}" ++
    "*{box-sizing:border-box;margin:0;padding:0;}" ++
    "html,body{width:100%;height:100%;overflow:hidden;}" ++
    "body{background:var(--bg);color:var(--tx);font-family:'JetBrains Mono',monospace;}" ++

    "header{height:56px;position:sticky;top:0;z-index:100;padding:.55rem 1rem;border-bottom:1px solid var(--bd);display:flex;align-items:center;gap:1rem;background:#0a0a0fee;backdrop-filter:blur(8px);}" ++
    "h1{font-family:'Syne',sans-serif;font-weight:800;font-size:1rem;color:var(--ac);white-space:nowrap;}" ++
    ".trm{font-size:.68rem;color:var(--dm);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:22vw;}" ++
    ".trm span{color:var(--tx);background:var(--bd);padding:.1em .4em;border-radius:3px;}" ++

    ".ctrls{display:flex;align-items:center;gap:.55rem;font-size:.58rem;color:var(--dm);white-space:nowrap;}" ++
    ".ctrl{display:flex;align-items:center;gap:.25rem;}" ++
    ".ctrl input[type=range]{width:78px;accent-color:var(--ac);}" ++
    ".ctrl span{color:var(--tx);min-width:1.8rem;display:inline-block;text-align:right;}" ++
    ".btn{border:1px solid var(--bd);background:#12121a;color:var(--tx);border-radius:5px;padding:.18rem .45rem;font-size:.58rem;font-family:'JetBrains Mono',monospace;cursor:pointer;}" ++
    ".btn:hover{border-color:var(--ac);}" ++

    ".leg{margin-left:auto;display:flex;gap:.65rem;font-size:.56rem;align-items:center;white-space:nowrap;}" ++
    ".li{display:flex;align-items:center;gap:.25rem;color:var(--dm);}" ++
    ".dot{width:6px;height:6px;border-radius:50%;}" ++

    ".main{display:grid;grid-template-columns:1fr 1fr;grid-template-rows:74vh 1fr;gap:1px;background:var(--bd);height:calc(100vh - 56px);overflow:hidden;}" ++
    ".graphPanel{grid-column:1 / 3;background:var(--bg);display:flex;flex-direction:column;overflow:hidden;}" ++
    ".phase{background:var(--bg);display:flex;flex-direction:column;overflow:hidden;min-width:0;min-height:0;}" ++

    ".ph{position:sticky;top:0;z-index:20;padding:.45rem .9rem;border-bottom:1px solid var(--bd);display:flex;align-items:center;gap:.5rem;flex-shrink:0;background:#0a0a0fee;backdrop-filter:blur(8px);}" ++
    ".pn{font-family:'Syne',sans-serif;font-weight:800;font-size:1.35rem;line-height:1;opacity:.18;}" ++
    ".pt{font-family:'Syne',sans-serif;font-weight:700;font-size:.68rem;letter-spacing:.06em;text-transform:uppercase;}" ++
    ".ps{font-size:.54rem;color:var(--dm);margin-left:auto;}" ++
    ".graphPanel .pn,.graphPanel .pt{color:var(--p1);}" ++
    ".p2 .pn,.p2 .pt{color:var(--p2);}" ++
    ".p4 .pn,.p4 .pt{color:var(--p4);}" ++

    ".pb{flex:1;overflow:auto;position:relative;min-height:0;}" ++
    "#cy{width:100%;height:100%;display:block;background:var(--bg);}" ++

    ".sideLabel{position:absolute;top:.7rem;font-family:'Syne',sans-serif;font-weight:800;font-size:.8rem;letter-spacing:.08em;opacity:.95;z-index:30;background:#12121acc;border:1px solid var(--bd);border-radius:7px;padding:.35rem .55rem;}" ++
    ".surfaceLabel{left:.8rem;color:var(--p1);}" ++
    ".delabLabel{right:.8rem;color:var(--p3);}" ++

    ".diffBox{position:absolute;right:.8rem;bottom:.8rem;background:#12121acc;border:1px solid var(--bd);border-radius:7px;padding:.38rem .55rem;font-size:.56rem;opacity:.88;z-index:30;}" ++
    ".ds{display:flex;align-items:center;gap:.35rem;margin-bottom:.08rem;}.ds:last-child{margin-bottom:0;}" ++
    ".dc{font-family:'Syne',sans-serif;font-weight:800;font-size:.7rem;min-width:1rem;text-align:right;}" ++

    ".hint{position:absolute;left:.8rem;bottom:.8rem;background:#12121aaa;border:1px solid var(--bd);border-radius:7px;padding:.35rem .55rem;font-size:.54rem;color:var(--dm);z-index:30;}" ++

    ".tp{padding:1rem 1.2rem;font-size:.72rem;line-height:1.85;white-space:pre-wrap;word-break:break-all;}" ++
    ".po{display:flex;align-items:center;justify-content:center;height:100%;font-size:1.7rem;font-family:'Syne',sans-serif;font-weight:800;color:var(--ac);padding:1.5rem;text-align:center;white-space:pre-wrap;}" ++

    ".tip{position:fixed;background:#12121a;border:1px solid var(--bd);border-radius:4px;padding:.35rem .65rem;font-size:.62rem;pointer-events:none;z-index:200;max-width:420px;word-break:break-all;opacity:0;transition:opacity .1s;}" ++
    ".tip.v{opacity:1;}" ++
    ".tk{color:var(--nd);font-weight:600;margin-bottom:.1rem;}" ++
    ".tv{color:var(--at);}" ++

    "::-webkit-scrollbar{width:4px;height:4px;}" ++
    "::-webkit-scrollbar-thumb{background:var(--bd);border-radius:999px;}"

  let body :=
    "<header><h1>Lean4 Graph Diff</h1>" ++
    "<div class=\"trm\">term: <span id=\"td\"></span></div>" ++

    "<div class=\"ctrls\">" ++
      "<label class=\"ctrl\">Font <input id=\"fontCtl\" type=\"range\" min=\"8\" max=\"26\" value=\"13\"><span id=\"fontVal\">13</span></label>" ++
      "<label class=\"ctrl\">Node <input id=\"nodeCtl\" type=\"range\" min=\"16\" max=\"60\" value=\"28\"><span id=\"nodeVal\">28</span></label>" ++
      "<button class=\"btn\" id=\"fitBtn\">Fit</button>" ++
      "<button class=\"btn\" id=\"smallBtn\">1+1</button>" ++
      "<button class=\"btn\" id=\"toggleCorrBtn\">Corr</button>" ++
      "<button class=\"btn\" id=\"toggleSameBtn\">Only diff</button>" ++
    "</div>" ++

    "<div class=\"leg\">" ++
      "<div class=\"li\"><div class=\"dot\" style=\"background:#89b4fa\"></div>Surface</div>" ++
      "<div class=\"li\"><div class=\"dot\" style=\"background:#a6e3a1\"></div>Delab</div>" ++
      "<div class=\"li\"><div class=\"dot\" style=\"background:#f38ba8\"></div>消失</div>" ++
      "<div class=\"li\"><div class=\"dot\" style=\"background:#f9e2af\"></div>対応候補</div>" ++
    "</div></header>" ++

    "<div class=\"main\">" ++

    "<div class=\"graphPanel\">" ++
      "<div class=\"ph\"><div class=\"pn\">Diff</div><div class=\"pt\">Surface Syntax ↔ Delaborated Syntax</div><div class=\"ps\">赤: Surfaceだけ / 緑: Delabだけ / 点線: 対応候補</div></div>" ++
      "<div class=\"pb\">" ++
        "<div id=\"cy\"></div>" ++
        "<div class=\"sideLabel surfaceLabel\">Surface Syntax</div>" ++
        "<div class=\"sideLabel delabLabel\">Delaborated Syntax</div>" ++
        "<div class=\"hint\">Drag: pan / Wheel: zoom / Click: 周辺強調 / Corr: 対応候補の表示切替</div>" ++
        "<div class=\"diffBox\">" ++
          "<div class=\"ds\"><div class=\"dc\" style=\"color:var(--rm)\" id=\"removedCnt\">0</div><div style=\"color:var(--dm)\">Surface only</div></div>" ++
          "<div class=\"ds\"><div class=\"dc\" style=\"color:var(--ad)\" id=\"addedCnt\">0</div><div style=\"color:var(--dm)\">Delab only</div></div>" ++
          "<div class=\"ds\"><div class=\"dc\" style=\"color:var(--ch)\" id=\"corrCnt\">0</div><div style=\"color:var(--dm)\">Correspondence</div></div>" ++
        "</div>" ++
      "</div>" ++
    "</div>" ++

    "<div class=\"phase p2\">" ++
      "<div class=\"ph\"><div class=\"pn\">2</div><div class=\"pt\">Elaborated Expr</div><div class=\"ps\">型情報・暗黙引数・型クラス解決後</div></div>" ++
      "<div class=\"pb\"><div class=\"tp\" id=\"p2\"></div></div>" ++
    "</div>" ++

    "<div class=\"phase p4\">" ++
      "<div class=\"ph\"><div class=\"pn\">4</div><div class=\"pt\">Pretty Printed</div><div class=\"ps\">最終出力</div></div>" ++
      "<div class=\"pb\"><div class=\"po\" id=\"p4\"></div></div>" ++
    "</div>" ++

    "</div>" ++
    "<div class=\"tip\" id=\"tip\"><div class=\"tk\" id=\"tk\"></div><div class=\"tv\" id=\"tv\"></div></div>"

  let js :=
    "const D=window.LEAN_DATA;" ++
    "document.getElementById('td').textContent=D.term||'';" ++
    "document.getElementById('p2').textContent=D.phase2||'';" ++
    "document.getElementById('p4').textContent=D.phase4||'';" ++

    "const tip=document.getElementById('tip');" ++
    "function showTip(e,d){" ++
      "document.getElementById('tk').textContent=d.label||d.id||'';" ++
      "document.getElementById('tv').textContent='phase='+d.phase+' / type='+d.type+' / diff='+d.diff+' / path='+d.path;" ++
      "tip.classList.add('v');moveTip(e);" ++
    "}" ++
    "function moveTip(e){tip.style.left=(e.clientX+14)+'px';tip.style.top=(e.clientY-8)+'px';}" ++
    "function hideTip(){tip.classList.remove('v');}" ++

    "function labelOf(n){" ++
      "return n.kind || n.val || n.type || 'missing';" ++
    "}" ++

    "function shortLabel(n){" ++
      "const l=labelOf(n);" ++
      "return l.length>28?l.slice(0,26)+'…':l;" ++
    "}" ++

    "function cmpKey(n,p=''){" ++
      "return p+'/'+(n.kind||n.type)+(n.val?':'+n.val:'');" ++
    "}" ++

    "function labelKey(n){" ++
      "return (n.type||'')+'|'+(n.kind||'')+'|'+(n.val||'');" ++
    "}" ++

    "function collectPathKeys(n,p='',set=new Set()){" ++
      "const k=cmpKey(n,p);set.add(k);" ++
      "if(n.children)n.children.forEach((c,i)=>collectPathKeys(c,k+'['+i+']',set));" ++
      "return set;" ++
    "}" ++

    "function flattenDiffTree(root,prefix,phase,baseX,pathKeysOther){" ++
      "let nodes=[];let edges=[];let labelBuckets={};let order=0;" ++
      "const depthGap=125;" ++
      "const rowGap=68;" ++
      "const topY=120;" ++
      "function walk(n,depth,parentId,path,recursivePath){" ++
        "const id=prefix+path;" ++
        "const k=cmpKey(n,recursivePath);" ++
        "const existsOther=pathKeysOther.has(k);" ++
        "let diff='same';" ++
        "if(phase==='surface' && !existsOther) diff='removed';" ++
        "if(phase==='delab' && !existsOther) diff='added';" ++
        "const label=shortLabel(n);" ++
        "const fullLabel=labelOf(n);" ++
        "const key=labelKey(n);" ++
        "const x=baseX + depth*depthGap;" ++
        "const y=topY + order*rowGap;" ++
        "order++;" ++
        "nodes.push({data:{id:id,label:label,fullLabel:fullLabel,phase:phase,type:n.type||'',kind:n.kind||'',val:n.val||'',diff:diff,path:path,key:key},position:{x:x,y:y}});" ++
        "if(!labelBuckets[key])labelBuckets[key]=[];" ++
        "labelBuckets[key].push(id);" ++
        "if(parentId)edges.push({data:{id:'child_'+parentId+'_'+id,source:parentId,target:id,kind:'child',phase:phase}});" ++
        "if(n.children)n.children.forEach((c,i)=>walk(c,depth+1,id,path+'_'+i,k+'['+i+']'));" ++
      "}" ++
      "walk(root,0,null,'0','');" ++
      "return {nodes:nodes,edges:edges,buckets:labelBuckets,count:order};" ++
    "}" ++

    "const sKeys=collectPathKeys(D.tree1);" ++
    "const dKeys=collectPathKeys(D.tree3);" ++

    -- 左右2列の手動配置。小さい式でも下に寄りすぎない。
    "const s=flattenDiffTree(D.tree1,'s','surface',90,dKeys);" ++
    "const d=flattenDiffTree(D.tree3,'d','delab',820,sKeys);" ++

    "let corr=[];" ++
    "let corrN=0;" ++
    "Object.keys(s.buckets).forEach(k=>{" ++
      "const a=s.buckets[k]||[];" ++
      "const b=d.buckets[k]||[];" ++
      "const m=Math.min(a.length,b.length);" ++
      "for(let i=0;i<m;i++){" ++
        "corr.push({data:{id:'corr_'+corrN,source:a[i],target:b[i],kind:'corr'}});" ++
        "corrN++;" ++
      "}" ++
    "});" ++

    "const elements=[...s.nodes,...d.nodes,...s.edges,...d.edges,...corr];" ++
    "const removed=s.nodes.filter(n=>n.data.diff==='removed').length;" ++
    "const added=d.nodes.filter(n=>n.data.diff==='added').length;" ++
    "document.getElementById('removedCnt').textContent=removed;" ++
    "document.getElementById('addedCnt').textContent=added;" ++
    "document.getElementById('corrCnt').textContent=corr.length;" ++

    "const cy=cytoscape({" ++
      "container:document.getElementById('cy')," ++
      "elements:elements," ++
      "wheelSensitivity:0.18," ++
      "layout:{name:'preset'}," ++
      "style:[" ++
        "{selector:'node',style:{" ++
          "'label':'data(label)'," ++
          "'font-family':'JetBrains Mono'," ++
          "'font-size':'var(--node-font)'," ++
          "'color':'#cdd6f4'," ++
          "'text-valign':'center'," ++
          "'text-wrap':'wrap'," ++
          "'text-max-width':'150px'," ++
          "'text-background-color':'#0a0a0f'," ++
          "'text-background-opacity':0.75," ++
          "'text-background-padding':'3px'," ++
          "'width':'var(--node-size)'," ++
          "'height':'var(--node-size)'," ++
          "'border-width':2," ++
          "'background-color':'#1a1a30'," ++
          "'border-color':'#cba6f7'" ++
        "}}," ++

        "{selector:'node[phase=\"surface\"]',style:{'background-color':'#0a1a30','border-color':'#89b4fa','text-halign':'right','text-margin-x':-10}}," ++
        "{selector:'node[phase=\"delab\"]',style:{'background-color':'#0a2518','border-color':'#a6e3a1','text-halign':'left','text-margin-x':10}}," ++
        "{selector:'node[diff=\"removed\"]',style:{'background-color':'#301018','border-color':'#f38ba8','border-width':4}}," ++
        "{selector:'node[diff=\"added\"]',style:{'background-color':'#0e2d18','border-color':'#a6e3a1','border-width':4}}," ++
        "{selector:'node[type=\"atom\"]',style:{'shape':'round-rectangle'}}," ++
        "{selector:'node[type=\"ident\"]',style:{'shape':'diamond'}}," ++
        "{selector:'node[type=\"node\"]',style:{'shape':'ellipse'}}," ++

        "{selector:'edge[kind=\"child\"]',style:{" ++
          "'width':1.2,'line-color':'#1e1e2e','target-arrow-color':'#1e1e2e','target-arrow-shape':'triangle','curve-style':'bezier','opacity':0.85" ++
        "}}," ++
        "{selector:'edge[kind=\"corr\"]',style:{" ++
          "'width':1.5,'line-color':'#f9e2af','target-arrow-color':'#f9e2af','target-arrow-shape':'vee','curve-style':'bezier','line-style':'dashed','opacity':0.35" ++
        "}}," ++
        "{selector:'.faded',style:{'opacity':0.10}}," ++
        "{selector:'.selectedFocus',style:{'border-width':6,'border-color':'#f5c2e7'}}" ++
      "]" ++
    "});" ++

    "cy.on('mouseover','node',evt=>{" ++
      "const d=evt.target.data();" ++
      "showTip(evt.originalEvent,{...d,label:d.fullLabel||d.label});" ++
    "});" ++
    "cy.on('mousemove','node',evt=>moveTip(evt.originalEvent));" ++
    "cy.on('mouseout','node',hideTip);" ++

    "cy.on('tap','node',evt=>{" ++
      "const n=evt.target;" ++
      "const connected=n.connectedEdges();" ++
      "cy.elements().removeClass('faded selectedFocus');" ++
      "n.addClass('selectedFocus');" ++
      "cy.elements().not(n).not(connected).not(connected.connectedNodes()).addClass('faded');" ++
    "});" ++
    "cy.on('tap',evt=>{if(evt.target===cy)cy.elements().removeClass('faded selectedFocus');});" ++

    "function applySizes(){" ++
      "const f=document.getElementById('fontCtl').value;" ++
      "const ns=document.getElementById('nodeCtl').value;" ++
      "document.documentElement.style.setProperty('--node-font',f+'px');" ++
      "document.documentElement.style.setProperty('--node-size',ns+'px');" ++
      "document.getElementById('fontVal').textContent=f;" ++
      "document.getElementById('nodeVal').textContent=ns;" ++
      "cy.style().update();" ++
    "}" ++

    "document.getElementById('fontCtl').addEventListener('input',applySizes);" ++
    "document.getElementById('nodeCtl').addEventListener('input',applySizes);" ++

    "document.getElementById('fitBtn').addEventListener('click',()=>{" ++
      "document.getElementById('fontCtl').value=14;" ++
      "document.getElementById('nodeCtl').value=30;" ++
      "applySizes();" ++
      "cy.fit(undefined,55);" ++
    "});" ++

    "document.getElementById('smallBtn').addEventListener('click',()=>{" ++
      "document.getElementById('fontCtl').value=20;" ++
      "document.getElementById('nodeCtl').value=44;" ++
      "applySizes();" ++
      "cy.fit(undefined,90);" ++
      "cy.zoom(cy.zoom()*1.35);" ++
    "});" ++

    "let corrVisible=true;" ++
    "document.getElementById('toggleCorrBtn').addEventListener('click',()=>{" ++
      "corrVisible=!corrVisible;" ++
      "cy.edges('[kind=\"corr\"]').style('display',corrVisible?'element':'none');" ++
    "});" ++

    "let onlyDiff=false;" ++
    "document.getElementById('toggleSameBtn').addEventListener('click',()=>{" ++
      "onlyDiff=!onlyDiff;" ++
      "cy.elements().removeClass('faded selectedFocus');" ++
      "if(onlyDiff){" ++
        "cy.nodes('[diff=\"same\"]').addClass('faded');" ++
        "cy.edges('[kind=\"child\"]').addClass('faded');" ++
      "}else{" ++
        "cy.elements().removeClass('faded');" ++
      "}" ++
    "});" ++

    -- 初期表示。小さい式でも中央に寄せる。
    "setTimeout(()=>{" ++
      "cy.fit(undefined,65);" ++
      "if(cy.nodes().length<=14){" ++
        "document.getElementById('smallBtn').click();" ++
      "}" ++
    "},100);"

  let html :=
    "<!DOCTYPE html><html lang=\"ja\"><head><meta charset=\"UTF-8\"><title>Lean4 Graph Diff</title>" ++
    "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.28.1/cytoscape.min.js\"></script>" ++
    "<link href=\"https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&family=Syne:wght@700;800&display=swap\" rel=\"stylesheet\">" ++
    "<style>" ++ css ++ "</style></head><body>" ++
    body ++
    "<script>" ++ data ++ js ++ "</script>" ++
    "</body></html>"

  IO.FS.writeFile outPath html

-- ===== メインコマンド =====

elab "#analyze_term " t:term : command => do
  Command.liftTermElabM do
    let tree1Json := syntaxToJson t
    let termStr   := (← PrettyPrinter.ppTerm t).pretty

    let e ← elabTerm t none
    synthesizeSyntheticMVarsNoPostponing
    let e ← instantiateMVars e
    let phase2Str := toString e

    let delab_t ← PrettyPrinter.delab e
    let tree3Json := syntaxToJson delab_t

    let fmt ← PrettyPrinter.ppTerm delab_t
    let phase4Str := fmt.pretty

    liftM (writeAnalysisHtml termStr phase2Str phase4Str tree1Json tree3Json)
    logInfo m!"✓ lean_graph_diff.html を生成しました。ブラウザで開いてください。"

end LeanFormatterLab

#analyze_term (1 + 1)