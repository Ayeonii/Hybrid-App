(window.webpackJsonp=window.webpackJsonp||[]).push([[2],{145:function(e,t,n){"use strict";n.d(t,"c",(function(){return v})),n.d(t,"a",(function(){return w})),n.d(t,"d",(function(){return E})),n.d(t,"b",(function(){return x})),n.d(t,"e",(function(){return T}));n(140),n(155),n(141),n(156),n(84),n(142),n(85),n(143),n(86),n(48),n(157);var r=n(0),a=n.n(r),o=n(255),i=n(215),c=n(257),l=n(260),u=n(281),s=n(275),f=n(274);function m(e,t){return function(e){if(Array.isArray(e))return e}(e)||function(e,t){if("undefined"==typeof Symbol||!(Symbol.iterator in Object(e)))return;var n=[],r=!0,a=!1,o=void 0;try{for(var i,c=e[Symbol.iterator]();!(r=(i=c.next()).done)&&(n.push(i.value),!t||n.length!==t);r=!0);}catch(e){a=!0,o=e}finally{try{r||null==c.return||c.return()}finally{if(a)throw o}}return n}(e,t)||function(e,t){if(!e)return;if("string"==typeof e)return d(e,t);var n=Object.prototype.toString.call(e).slice(8,-1);"Object"===n&&e.constructor&&(n=e.constructor.name);if("Map"===n||"Set"===n)return Array.from(e);if("Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))return d(e,t)}(e,t)||function(){throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}()}function d(e,t){(null==t||t>e.length)&&(t=e.length);for(var n=0,r=new Array(t);n<t;n++)r[n]=e[n];return r}function g(e,t,n,r,a,o,i){try{var c=e[o](i),l=c.value}catch(e){return void n(e)}c.done?t(l):Promise.resolve(l).then(r,a)}function h(e){return function(){var t=this,n=arguments;return new Promise((function(r,a){var o=e.apply(t,n);function i(e){g(o,r,a,i,c,"next",e)}function c(e){g(o,r,a,i,c,"throw",e)}i(void 0)}))}}function y(){return(y=Object.assign||function(e){for(var t=1;t<arguments.length;t++){var n=arguments[t];for(var r in n)Object.prototype.hasOwnProperty.call(n,r)&&(e[r]=n[r])}return e}).apply(this,arguments)}function p(e,t){if(null==e)return{};var n,r,a=function(e,t){if(null==e)return{};var n,r,a={},o=Object.keys(e);for(r=0;r<o.length;r++)n=o[r],t.indexOf(n)>=0||(a[n]=e[n]);return a}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(r=0;r<o.length;r++)n=o[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}const b=Object(o.a)(e=>({root:{textAlign:"center",padding:10,overflow:"scroll",display:"block","&::-webkit-scrollbar":{display:"none"}},btn:{width:"60%",margin:10,textTransform:"none"},card:{width:"90%",marginLeft:"auto",marginRight:"auto",marginTop:15,marginBottom:15,padding:10,backgroundColor:"#fdfdfd"},field:{margin:10,width:"40%",minWidth:200,"-ms-user-select":"text","-moz-user-select":"-moz-text","-webkit-user-select":"text","-khtml-user-select":"text","user-select":"text"},titleRoot:{padding:5,color:e.overrides.MuiButton.contained.backgroundColor},image:{maxWidth:"90%",maxHeight:"50%",margin:"auto",width:"auto"}})),v=function(e){const t=b(),n=e.src,r=p(e,["src"]);return a.a.createElement(f.a,y({className:t.image,component:"img",src:n},r))},w=function(e){var t=this;const n=b(),r=e.funName,o=e.text,c=(e.position,e.args),l=e.dialog,u=e.clickAfter,s=p(e,["funName","text","position","args","dialog","clickAfter"]);return a.a.createElement(i.a,y({variant:"contained",color:"primary",onClick:h(regeneratorRuntime.mark((function e(){var n,a;return regeneratorRuntime.wrap((function(e){for(;;)switch(e.prev=e.next){case 0:return e.next=2,$flex[r].apply(t,c);case 2:n=e.sent,u&&u(n),l&&(a="","object"==typeof n?Object.keys(n).forEach(e=>{a.concat(e).concat(" : ").concat(n[e]).concat("/n")}):a=String(n),$flex.Dialog(o,a,{basic:"확인"},!0,!0));case 5:case"end":return e.stop()}}),e)}))),className:n.btn},s),o)},E=function(e){const t=b(),n=Object.assign({},e);return a.a.createElement(u.a,y({variant:"outlined",size:"small",className:t.field},n))},x=function(e){const t=b(),n=e.children,r=e.title,o=p(e,["children","title"]);return a.a.createElement(c.a,y({className:t.card},o),a.a.createElement(l.a,{classes:{root:t.titleRoot},titleTypographyProps:{variant:"h5"},title:r}),a.a.createElement(s.a,{style:{margin:5}}),n)},T=function(e){const t=b(),n=e.children,r=p(e,["children"]),o=m(a.a.useState(window.outerHeight),2),i=o[0],c=o[1];return a.a.useEffect(()=>{window.addEventListener("resize",()=>{c(window.outerHeight)})}),a.a.createElement("div",y({className:t.root,style:{height:i-76}},r),n)}},273:function(e,t,n){"use strict";n.r(t),n.d(t,"default",(function(){return u}));n(140),n(141),n(84),n(149),n(142),n(143),n(48);var r=n(0),a=n.n(r),o=n(145);function i(e,t){return function(e){if(Array.isArray(e))return e}(e)||function(e,t){if("undefined"==typeof Symbol||!(Symbol.iterator in Object(e)))return;var n=[],r=!0,a=!1,o=void 0;try{for(var i,c=e[Symbol.iterator]();!(r=(i=c.next()).done)&&(n.push(i.value),!t||n.length!==t);r=!0);}catch(e){a=!0,o=e}finally{try{r||null==c.return||c.return()}finally{if(a)throw o}}return n}(e,t)||function(e,t){if(!e)return;if("string"==typeof e)return c(e,t);var n=Object.prototype.toString.call(e).slice(8,-1);"Object"===n&&e.constructor&&(n=e.constructor.name);if("Map"===n||"Set"===n)return Array.from(e);if("Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))return c(e,t)}(e,t)||function(){throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}()}function c(e,t){(null==t||t>e.length)&&(t=e.length);for(var n=0,r=new Array(t);n<t;n++)r[n]=e[n];return r}const l=[{name:"Show Dialog",fun:"Dialog"},{name:"Show Bottom Dialog",fun:"Dialog"},{name:"Short Toast",fun:"Toast"},{name:"Long Toast",fun:"Toast"}];function u(){const e=e=>{const t=e.position,n=l[t],r=i(a.a.useState([]),2),c=r[0],u=r[1],s=(e,t)=>{c[e]=t,u(c)};switch(t){case 0:return a.a.useEffect(()=>{s(0,"Title Text"),s(1,"Body Text"),s(2,{basic:"확인",destructive:"삭제",cancel:"취소"}),s(3,!0),s(4,!0)}),a.a.createElement(o.b,{title:"Dioalog Test"},a.a.createElement(o.d,{label:"Title Text",onChange:e=>{s(0,e.target.value)}}),a.a.createElement(o.d,{label:"Body Text",onChange:e=>{s(1,e.target.value)}}),a.a.createElement(o.a,{funName:n.fun,text:n.name,position:t,args:c}));case 1:return a.a.useEffect(()=>{s(0,"Title Text"),s(1,"Body Text"),s(2,{basic:"확인",destructive:"삭제",cancel:"취소"}),s(3,!1),s(4,!0)}),a.a.createElement(o.b,{title:"Bottom Dioalog Test"},a.a.createElement(o.d,{label:"Title Text",onChange:e=>{s(0,e.target.value)}}),a.a.createElement(o.d,{label:"Body Text",onChange:e=>{s(1,e.target.value)}}),a.a.createElement(o.a,{funName:n.fun,text:n.name,position:t,args:c}));case 2:return a.a.useEffect(()=>{s(0,"Short Toast Message"),s(1,!0)}),a.a.createElement(o.b,{title:"Short Toast Test"},a.a.createElement(o.d,{label:"Short Toast Message",onChange:e=>{s(0,e.target.value)}}),a.a.createElement(o.a,{funName:n.fun,text:n.name,position:t,args:c}));case 3:return a.a.useEffect(()=>{s(0,"Long Toast Message"),s(1,!1)}),a.a.createElement(o.b,{title:"Long Toast Test"},a.a.createElement(o.d,{label:"Long Toast Message",onChange:e=>{s(0,e.target.value)}}),a.a.createElement(o.a,{funName:n.fun,text:n.name,position:t,args:c}));default:return a.a.createElement("div",null)}};return a.a.createElement(o.e,null,l.map((t,n)=>a.a.createElement(e,{position:n,key:n})))}}}]);