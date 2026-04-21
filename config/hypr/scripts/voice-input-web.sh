#!/bin/bash
# Voice input with VU meter

TEMP_HTML="/tmp/voice-input.html"

cat > "$TEMP_HTML" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>🎤 Voice Input</title>
<style>
*{box-sizing:border-box}
body{background:#0d0d0d;display:flex;flex-direction:column;align-items:center;justify-content:center;height:100vh;margin:0;font-family:-apple-system,system-ui,sans-serif;color:#fff}
h1{font-size:72px;margin:0}
#mic{width:200px;height:200px;border-radius:50%;border:none;background:#e74c3c;color:white;font-size:96px;cursor:pointer;box-shadow:0 0 60px rgba(231,76,60,0.6);transition:all 0.2s}
#mic.recording{background:#27ae60;box-shadow:0 0 80px rgba(39,174,96,0.8);animation:pulse 1s infinite}
@keyframes pulse{0%,100%{transform:scale(1)}50%{transform:scale(1.08)}}
#status{color:#888;font-size:28px;margin:20px 0 10px}
#hint{color:#444;font-size:16px}
#vu{width:300px;height:20px;background:#222;border-radius:10px;margin:20px 0;overflow:hidden}
#vu-bar{height:100%;width:0%;background:linear-gradient(90deg,#27ae60,#f1c40f,#e74c3c);transition:width 0.05s}
#level{font-size:48px;color:#27ae60;font-weight:bold;height:60px}
</style></head>
<body>
<h1>🎤</h1>
<div id="level"></div>
<div id="vu"><div id="vu-bar"></div></div>
<button id="mic">🎤</button>
<p id="status">Tap mic to speak</p>
<p id="hint">Close tab, press F7 to type</p>
<script>
const r=new (window.SpeechRecognition||window.webkitSpeechRecognition)();
const b=document.getElementById('mic'),s=document.getElementById('status');
const v=document.getElementById('vu-bar'),l=document.getElementById('level');

// Check audio API for level
if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
    navigator.mediaDevices.getUserMedia({audio:true}).then(stream=>{
        const ctx=new AudioContext();
        const an=ctx.createAnalyser();
        an.fftSize=256;
        const src=ctx.createMediaStreamSource(stream);
        src.connect(an);
        function draw(){
            if(!b.classList.contains('recording')){requestAnimationFrame(draw);return}
            const data=new Uint8Array(an.frequencyBinCount);
            an.getByteFrequencyData(data);
            const avg=data.reduce((a,b)=>a+b)/data.length;
            const pct=Math.min(100,avg*2);
            v.style.width=pct+'%';
            l.textContent=Math.round(pct)+'%';
            requestAnimationFrame(draw);
        }
        r.onstart=draw;
        r.onend=()=>{v.style.width='0%';l.textContent='';}
    });
}

r.onstart=()=>{b.classList.add('recording');s.textContent='Listening...'};
r.onresult=e=>{
  const t=e.results[0][0].transcript;
  navigator.clipboard.writeText(t).then(()=>{s.textContent='✓ Copied!';l.textContent='✓';});
};
r.onerror=ev=>{b.classList.remove('recording');s.textContent='Error: '+ev.error;l.textContent='✗';setTimeout(()=>l.textContent='',2000)};
r.onend=()=>b.classList.remove('recording');
b.onclick=()=>r.start();
</script>
</body>
</html>
HTMLEOF

firefox "$TEMP_HTML" &