(window.webpackJsonp=window.webpackJsonp||[]).push([[7],{145:function(t,e,n){"use strict";n.d(e,"a",(function(){return h})),n.d(e,"c",(function(){return v})),n.d(e,"b",(function(){return w})),n.d(e,"d",(function(){return O}));n(139),n(155),n(140),n(156),n(84),n(141),n(85),n(142),n(86),n(48),n(157);var r=n(0),o=n.n(r),a=n(255),i=n(214),c=n(257),u=n(260),l=n(280),s=n(274);function f(t,e){return function(t){if(Array.isArray(t))return t}(t)||function(t,e){if("undefined"==typeof Symbol||!(Symbol.iterator in Object(t)))return;var n=[],r=!0,o=!1,a=void 0;try{for(var i,c=t[Symbol.iterator]();!(r=(i=c.next()).done)&&(n.push(i.value),!e||n.length!==e);r=!0);}catch(t){o=!0,a=t}finally{try{r||null==c.return||c.return()}finally{if(o)throw a}}return n}(t,e)||function(t,e){if(!t)return;if("string"==typeof t)return d(t,e);var n=Object.prototype.toString.call(t).slice(8,-1);"Object"===n&&t.constructor&&(n=t.constructor.name);if("Map"===n||"Set"===n)return Array.from(t);if("Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))return d(t,e)}(t,e)||function(){throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}()}function d(t,e){(null==e||e>t.length)&&(e=t.length);for(var n=0,r=new Array(e);n<e;n++)r[n]=t[n];return r}function m(){return(m=Object.assign||function(t){for(var e=1;e<arguments.length;e++){var n=arguments[e];for(var r in n)Object.prototype.hasOwnProperty.call(n,r)&&(t[r]=n[r])}return t}).apply(this,arguments)}function p(t,e,n,r,o,a,i){try{var c=t[a](i),u=c.value}catch(t){return void n(t)}c.done?e(u):Promise.resolve(u).then(r,o)}function y(t){return function(){var e=this,n=arguments;return new Promise((function(r,o){var a=t.apply(e,n);function i(t){p(a,r,o,i,c,"next",t)}function c(t){p(a,r,o,i,c,"throw",t)}i(void 0)}))}}function g(t,e){if(null==t)return{};var n,r,o=function(t,e){if(null==t)return{};var n,r,o={},a=Object.keys(t);for(r=0;r<a.length;r++)n=a[r],e.indexOf(n)>=0||(o[n]=t[n]);return o}(t,e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(t);for(r=0;r<a.length;r++)n=a[r],e.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(t,n)&&(o[n]=t[n])}return o}const b=Object(a.a)(()=>({root:{textAlign:"center",padding:10,overflow:"scroll",display:"block","&::-webkit-scrollbar":{display:"none"}},btn:{width:"60%",margin:10,textTransform:"none"},card:{width:"90%",marginLeft:"auto",marginRight:"auto",marginTop:15,marginBottom:15,padding:10,backgroundColor:"#fdfdfd"},field:{margin:10,width:"40%",minWidth:200},titleRoot:{padding:5}})),h=function(t){var e=this;const n=b(),r=t.funName,a=t.text,c=(t.position,t.args),u=t.dialog,l=g(t,["funName","text","position","args","dialog"]);return o.a.createElement(i.a,m({variant:"contained",color:"primary",onClick:y(regeneratorRuntime.mark((function t(){var n,o;return regeneratorRuntime.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:return t.next=2,$flex[r].apply(e,c);case 2:n=t.sent,u&&(o="","object"==typeof n?Object.keys(n).forEach(t=>{o.concat(t).concat(" : ").concat(n[t]).concat("/n")}):o=String(n),$flex.Dialog(a,o,[["확인","basic"]],"alert",!0));case 4:case"end":return t.stop()}}),t)}))),className:n.btn},l),a)},v=function(t){const e=b(),n=Object.assign({},t);return o.a.createElement(l.a,m({variant:"outlined",size:"small",className:e.field},n))},w=function(t){const e=b(),n=t.children,r=t.title,a=g(t,["children","title"]);return o.a.createElement(c.a,m({className:e.card},a),o.a.createElement(u.a,{classes:{root:e.titleRoot},titleTypographyProps:{variant:"h6"},title:r}),o.a.createElement(s.a,{style:{margin:5}}),n)},O=function(t){const e=b(),n=t.children,r=g(t,["children"]),a=f(o.a.useState(window.outerHeight),2),i=a[0],c=a[1];return o.a.useEffect(()=>{window.addEventListener("resize",()=>{c(window.outerHeight)})}),o.a.createElement("div",m({className:e.root,style:{height:i-76}},r),n)}},275:function(t,e,n){"use strict";n.r(e),n.d(e,"default",(function(){return l}));n(139),n(140),n(84),n(149),n(141),n(142),n(48);var r=n(0),o=n.n(r),a=n(145);function i(t,e){return function(t){if(Array.isArray(t))return t}(t)||function(t,e){if("undefined"==typeof Symbol||!(Symbol.iterator in Object(t)))return;var n=[],r=!0,o=!1,a=void 0;try{for(var i,c=t[Symbol.iterator]();!(r=(i=c.next()).done)&&(n.push(i.value),!e||n.length!==e);r=!0);}catch(t){o=!0,a=t}finally{try{r||null==c.return||c.return()}finally{if(o)throw a}}return n}(t,e)||function(t,e){if(!t)return;if("string"==typeof t)return c(t,e);var n=Object.prototype.toString.call(t).slice(8,-1);"Object"===n&&t.constructor&&(n=t.constructor.name);if("Map"===n||"Set"===n)return Array.from(t);if("Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))return c(t,e)}(t,e)||function(){throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}()}function c(t,e){(null==e||e>t.length)&&(e=t.length);for(var n=0,r=new Array(e);n<e;n++)r[n]=t[n];return r}const u=[{name:"Network",fun:"Network"},{name:"Location",fun:"Location"}];function l(){const t=t=>{const e=t.position,n=u[e],r=i(o.a.useState([]),2),c=r[0];r[1];switch(e){case 0:return o.a.createElement(a.b,{title:"Network Test"},o.a.createElement(a.a,{funName:n.fun,text:n.name,position:e,dialog:!0,args:c}));case 1:return o.a.createElement(a.b,{title:"Location Test"},o.a.createElement(a.a,{funName:n.fun,text:n.name,position:e,dialog:!0,args:c}));default:return o.a.createElement("div",null)}};return o.a.createElement(a.d,null,u.map((e,n)=>o.a.createElement(t,{position:n,key:n})))}}}]);