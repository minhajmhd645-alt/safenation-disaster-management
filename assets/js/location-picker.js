'use strict';
(() => {
 const boxes=[...document.querySelectorAll('.location-fields')];if(!boxes.length)return;
 async function request(form,params,signal){
  const body=new URLSearchParams({csrf:form.querySelector('[name=csrf]').value,...params});
  const response=await fetch('index.php?page=location-data',{method:'POST',body,signal});
  const data=await response.json();if(!response.ok)throw new Error(data.error||'Location lookup failed. Please try again.');return data;
 }
 const boundaries=request(boxes[0].closest('form'),{mode:'districts'}).catch(()=>null);
 function inRing(x,y,ring){let inside=false;for(let i=0,j=ring.length-1;i<ring.length;j=i++){const p=ring[i],q=ring[j];if((p[1]>y)!==(q[1]>y)&&x<(q[0]-p[0])*(y-p[1])/(q[1]-p[1])+p[0])inside=!inside;}return inside;}
 function districtAt(data,lat,lng){
  if(!data)return null;
  for(const f of data.features){const b=f.bbox;if(lng<b[0]||lat<b[1]||lng>b[2]||lat>b[3])continue;const polygons=f.geometry.type==='Polygon'?[f.geometry.coordinates]:f.geometry.coordinates;
   if(polygons.some(p=>inRing(lng,lat,p[0])&&!p.slice(1).some(r=>inRing(lng,lat,r))))return f.properties.name;
  }return null;
 }
 for(const box of boxes){
  const form=box.closest('form'),root=box.querySelector('.location-picker-map'),latInput=box.querySelector('[name=latitude]'),lngInput=box.querySelector('[name=longitude]'),area=box.querySelector('[name=area]'),address=form.querySelector('[name=address]'),status=box.querySelector('.geo-status'),query=box.querySelector('.place-query'),results=box.querySelector('.place-results'),find=box.querySelector('.place-search');
  let map=null,marker=null,lastPoint=null,revision=0,addressRevision=0,reverseAbort=null,searchAbort=null,searchRevision=0,geoRevision=0;
  address?.addEventListener('input',()=>addressRevision++);
  if(window.L){
   map=L.map(root,{scrollWheelZoom:false,minZoom:6,maxZoom:19,maxBounds:[[5.3,78.7],[10.4,82.7]]}).fitBounds([[5.85,79.45],[9.85,81.9]]);
   L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{maxZoom:19,attribution:'© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>'}).addTo(map);
   map.on('click',e=>choose(e.latlng.lat,e.latlng.lng));
   if(window.ResizeObserver)new ResizeObserver(()=>map.invalidateSize({pan:false})).observe(root);
  }else root.textContent='The map could not load. Enter coordinates below.';
  function place(lat,lng,zoom=false){
   lastPoint=[lat,lng];if(!map)return;
   if(!marker){marker=L.marker([lat,lng],{draggable:true,autoPan:true,title:'Selected location — drag to move',alt:'Selected location marker'}).addTo(map);marker.on('dragend',()=>{const p=marker.getLatLng();choose(p.lat,p.lng);});}
   else marker.setLatLng([lat,lng]);
   if(zoom)map.setView([lat,lng],15);else map.panTo([lat,lng]);
  }
  async function lookup(lat,lng,current){
   reverseAbort?.abort();reverseAbort=new AbortController();const aRevision=addressRevision;
   try{
    const data=await request(form,{mode:'reverse',latitude:lat,longitude:lng},reverseAbort.signal);
    if(current!==revision)return;
    if(data.district)area.value=data.district;
    if(address&&addressRevision===aRevision&&data.address)address.value=data.address;
    status.textContent=data.message|| (data.address?'Location selected. Check the suggested address before saving.':'Location selected. No address was found; enter a landmark or address manually.');
   }catch(e){if(e.name!=='AbortError'&&current===revision)status.textContent='Location selected. '+e.message;}
  }
  async function choose(lat,lng,label='',zoom=false){
   const current=++revision;reverseAbort?.abort();
   const data=await boundaries;if(current!==revision)return;
   const district=districtAt(data,lat,lng);
   if(!Number.isFinite(lat)||!Number.isFinite(lng)||lat<5.5||lat>10.2||lng<79||lng>82.5||(data&&!district)){
    status.textContent='Choose a point within Sri Lanka. For coastal locations, place the marker on land.';if(marker&&lastPoint)marker.setLatLng(lastPoint);return false;
   }
   latInput.value=lat.toFixed(7);lngInput.value=lng.toFixed(7);if(district)area.value=district;
   if(address){address.value=label;addressRevision++;}
   place(lat,lng,zoom);status.textContent='Location selected'+(district?' in '+district:'')+'. Looking up the address…';
   if(label){status.textContent='Location selected. Check the address and adjust the marker if needed.';}else lookup(lat,lng,current);
   return true;
  }
  const savedLat=Number(latInput.value),savedLng=Number(lngInput.value);
  if(latInput.value!==''&&lngInput.value!==''&&Number.isFinite(savedLat)&&Number.isFinite(savedLng)){place(savedLat,savedLng,true);status.textContent='Saved location shown. Click the map or drag the marker to change it.';}
  for(const input of [latInput,lngInput])input.addEventListener('change',()=>{if(latInput.value!==''&&lngInput.value!=='')choose(Number(latInput.value),Number(lngInput.value),'',true);});
  area.addEventListener('change',async()=>{++revision;reverseAbort?.abort();const data=await boundaries;const f=data?.features.find(f=>f.properties.name===area.value);if(f&&map){const b=f.bbox;map.fitBounds([[b[1],b[0]],[b[3],b[2]]]);status.textContent='Choose the exact point within '+area.value+'.';}});
  form.addEventListener('submit',e=>{if(query===document.activeElement){e.preventDefault();search();}});
  query.addEventListener('keydown',e=>{if(e.key==='Enter'){e.preventDefault();search();}});
  async function search(){
   const q=query.value.trim();if(q.length<2){status.textContent='Enter at least two characters to search.';return;}
   const current=++searchRevision;searchAbort?.abort();searchAbort=new AbortController();find.disabled=true;results.replaceChildren();status.textContent='Searching Sri Lanka…';
   try{
    const data=await request(form,{mode:'search',q},searchAbort.signal);if(current!==searchRevision)return;
    for(const r of data.results){const button=document.createElement('button');button.type='button';button.className='place-result';button.textContent=r.label;button.addEventListener('click',()=>{++geoRevision;choose(Number(r.latitude),Number(r.longitude),r.label,true);results.replaceChildren();});results.append(button);}
    status.textContent=(data.message?data.message+' ':'')+(data.results.length?'Select a result, then move the marker if needed.':'No matching places found. Try a nearby town or select the point on the map.');
   }catch(e){if(e.name!=='AbortError')status.textContent=e.message;}finally{if(current===searchRevision)find.disabled=false;}
  }
  find.addEventListener('click',search);
  box.querySelector('.lookup-address').addEventListener('click',()=>{if(latInput.value===''||lngInput.value===''){status.textContent='Select a point first.';return;}status.textContent='Looking up the address…';lookup(Number(latInput.value),Number(lngInput.value),++revision);});
  box.querySelector('.geolocate').addEventListener('click',function(){
   if(!navigator.geolocation){status.textContent='Location access is unavailable. Choose a point on the map.';return;}
   const current=++geoRevision,pointRevision=revision;this.disabled=true;status.textContent='Finding your location…';
   navigator.geolocation.getCurrentPosition(p=>{this.disabled=false;if(current!==geoRevision||pointRevision!==revision)return;choose(p.coords.latitude,p.coords.longitude,'',true);},()=>{this.disabled=false;if(pointRevision===revision)status.textContent='Location access failed or was declined. Search for a place or select a map point.';},{enableHighAccuracy:true,timeout:10000,maximumAge:30000});
  });
 }
})();
