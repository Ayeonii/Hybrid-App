(window.webpackJsonp=window.webpackJsonp||[]).push([[8],{145:function(e,t,r){"use strict";r.d(t,"c",(function(){return v})),r.d(t,"a",(function(){return w})),r.d(t,"d",(function(){return E})),r.d(t,"b",(function(){return S})),r.d(t,"e",(function(){return x}));r(140),r(141),r(155),r(84),r(142),r(85),r(143),r(48),r(156);var n=r(0),a=r.n(n),o=r(255),i=r(214),c=r(257),l=r(260),u=r(281),s=r(275),f=r(274);function m(e,t){return function(e){if(Array.isArray(e))return e}(e)||function(e,t){if("undefined"==typeof Symbol||!(Symbol.iterator in Object(e)))return;var r=[],n=!0,a=!1,o=void 0;try{for(var i,c=e[Symbol.iterator]();!(n=(i=c.next()).done)&&(r.push(i.value),!t||r.length!==t);n=!0);}catch(e){a=!0,o=e}finally{try{n||null==c.return||c.return()}finally{if(a)throw o}}return r}(e,t)||function(e,t){if(!e)return;if("string"==typeof e)return d(e,t);var r=Object.prototype.toString.call(e).slice(8,-1);"Object"===r&&e.constructor&&(r=e.constructor.name);if("Map"===r||"Set"===r)return Array.from(e);if("Arguments"===r||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(r))return d(e,t)}(e,t)||function(){throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}()}function d(e,t){(null==t||t>e.length)&&(t=e.length);for(var r=0,n=new Array(t);r<t;r++)n[r]=e[r];return n}function y(e,t,r,n,a,o,i){try{var c=e[o](i),l=c.value}catch(e){return void r(e)}c.done?t(l):Promise.resolve(l).then(n,a)}function p(e){return function(){var t=this,r=arguments;return new Promise((function(n,a){var o=e.apply(t,r);function i(e){y(o,n,a,i,c,"next",e)}function c(e){y(o,n,a,i,c,"throw",e)}i(void 0)}))}}function g(){return(g=Object.assign||function(e){for(var t=1;t<arguments.length;t++){var r=arguments[t];for(var n in r)Object.prototype.hasOwnProperty.call(r,n)&&(e[n]=r[n])}return e}).apply(this,arguments)}function h(e,t){if(null==e)return{};var r,n,a=function(e,t){if(null==e)return{};var r,n,a={},o=Object.keys(e);for(n=0;n<o.length;n++)r=o[n],t.indexOf(r)>=0||(a[r]=e[r]);return a}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(n=0;n<o.length;n++)r=o[n],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(a[r]=e[r])}return a}const b=Object(o.a)(e=>({root:{textAlign:"center",padding:10,overflow:"scroll",display:"block","&::-webkit-scrollbar":{display:"none"}},btn:{width:"60%",margin:10,textTransform:"none"},card:{width:"90%",marginLeft:"auto",marginRight:"auto",marginTop:15,marginBottom:15,padding:10,backgroundColor:"#fdfdfd"},field:{margin:10,width:"40%",minWidth:200,"-ms-user-select":"text","-moz-user-select":"-moz-text","-webkit-user-select":"text","-khtml-user-select":"text","user-select":"text"},titleRoot:{padding:5,color:e.overrides.MuiButton.contained.backgroundColor},image:{maxWidth:"90%",maxHeight:"50%",margin:"auto",width:"auto"}})),v=function(e){const t=b(),r=e.src,n=h(e,["src"]);return a.a.createElement(f.a,g({className:t.image,component:"img",src:r},n))},w=function(e){var t=this;const r=b(),n=e.funName,o=e.text,c=(e.position,e.args),l=e.dialog,u=e.clickAfter,s=h(e,["funName","text","position","args","dialog","clickAfter"]);return a.a.createElement(i.a,g({variant:"contained",color:"primary",onClick:p(regeneratorRuntime.mark((function e(){var r,a;return regeneratorRuntime.wrap((function(e){for(;;)switch(e.prev=e.next){case 0:return e.next=2,$flex[n].apply(t,c);case 2:r=e.sent,console.log(r),u&&null!=r&&u(r),l&&(a="",a="object"==typeof r||"array"==typeof r?JSON.stringify(r):String(r),$flex.Dialog(o,a,{basic:"확인"},!0,!0));case 6:case"end":return e.stop()}}),e)}))),className:r.btn},s),o)},E=function(e){const t=b(),r=Object.assign({},e);return a.a.createElement(u.a,g({variant:"outlined",size:"small",className:t.field},r))},S=function(e){const t=b(),r=e.children,n=e.title,o=h(e,["children","title"]);return a.a.createElement(c.a,g({className:t.card},o),a.a.createElement(l.a,{classes:{root:t.titleRoot},titleTypographyProps:{variant:"h5"},title:n}),a.a.createElement(s.a,{style:{margin:5}}),r)},x=function(e){const t=b(),r=e.children,n=h(e,["children"]),o=m(a.a.useState(window.outerHeight),2),i=o[0],c=o[1];return a.a.useEffect(()=>{window.addEventListener("resize",()=>{c(window.outerHeight)})}),a.a.createElement("div",g({className:t.root,style:{height:i-76}},n),r)}},277:function(e,t,r){"use strict";r.r(t),r.d(t,"default",(function(){return u}));r(140),r(141),r(84),r(149),r(142),r(143),r(48);var n=r(0),a=r.n(n),o=r(145);function i(e,t){return function(e){if(Array.isArray(e))return e}(e)||function(e,t){if("undefined"==typeof Symbol||!(Symbol.iterator in Object(e)))return;var r=[],n=!0,a=!1,o=void 0;try{for(var i,c=e[Symbol.iterator]();!(n=(i=c.next()).done)&&(r.push(i.value),!t||r.length!==t);n=!0);}catch(e){a=!0,o=e}finally{try{n||null==c.return||c.return()}finally{if(a)throw o}}return r}(e,t)||function(e,t){if(!e)return;if("string"==typeof e)return c(e,t);var r=Object.prototype.toString.call(e).slice(8,-1);"Object"===r&&e.constructor&&(r=e.constructor.name);if("Map"===r||"Set"===r)return Array.from(e);if("Arguments"===r||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(r))return c(e,t)}(e,t)||function(){throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}()}function c(e,t){(null==t||t>e.length)&&(t=e.length);for(var r=0,n=new Array(t);r<t;r++)n[r]=e[r];return n}const l=[{name:"QRCode Scan",fun:"QRCodeScan"},{name:"Select Img from Photos",fun:"PhotoByDeviceRatio"},{name:"Select multi Imgs from Photos",fun:"MultiPhotoByDeviceRatio"},{name:"Get Photo taken with Camera",fun:"CameraByDeviceRatio"}];function u(){const e=e=>{const t=e.position,r=l[t],n=i(a.a.useState([]),2),c=n[0],u=n[1],s=i(a.a.useState([]),2),f=s[0],m=s[1],d=(e,t)=>{c[e]=t,u(c)};switch(t){case 0:return a.a.createElement(o.b,{title:"QRCodeScan Test"},a.a.createElement(o.a,{funName:r.fun,text:r.name,position:t,dialog:!0,args:c}));case 1:return a.a.useEffect(()=>{d(0,1),d(1,!1)}),a.a.createElement(o.b,{title:"Select Img Test"},a.a.createElement(o.c,{src:f[0]}),a.a.createElement(o.a,{funName:r.fun,text:r.name,position:t,args:c,clickAfter:e=>{m([e.data])}}));case 2:return a.a.useEffect(()=>{d(0,1),d(1,!1)}),a.a.createElement(o.b,{title:"Select multi Imgs Test"},a.a.createElement(o.c,{src:f[0]}),a.a.createElement(o.c,{src:f[1]}),a.a.createElement(o.c,{src:f[2]}),a.a.createElement(o.c,{src:f[3]}),a.a.createElement(o.c,{src:f[4]}),a.a.createElement(o.a,{funName:r.fun,text:r.name,position:t,args:c,clickAfter:e=>{"array"==typeof e.data?m(e.data):m([])}}));case 3:return a.a.useEffect(()=>{d(0,1),d(1,!0)}),a.a.createElement(o.b,{title:"Camera Test"},a.a.createElement(o.c,{src:f[0]}),a.a.createElement(o.a,{funName:r.fun,text:r.name,position:t,args:c,clickAfter:e=>{m([e.data])}}));default:return a.a.createElement("div",null)}};return a.a.createElement(o.e,null,l.map((t,r)=>a.a.createElement(e,{position:r,key:r})))}}}]);