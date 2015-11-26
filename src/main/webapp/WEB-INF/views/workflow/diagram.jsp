﻿<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title>流程跟踪</title>
  <link rel="stylesheet" href="style.css" type="text/css" media="screen">
  <script src="js/jstools.js" type="text/javascript" charset="utf-8"></script>
  <script src="js/raphael.js" type="text/javascript" charset="utf-8"></script>
  
  <script src="js/jquery/jquery.js" type="text/javascript" charset="utf-8"></script>
  <script src="js/jquery/jquery.progressbar.js" type="text/javascript" charset="utf-8"></script>
  <script src="js/jquery/jquery.asyncqueue.js" type="text/javascript" charset="utf-8"></script>
  
  <script src="js/Color.js" type="text/javascript" charset="utf-8"></script>
  <script src="js/Polyline.js" type="text/javascript" charset="utf-8"></script>
  <script src="js/ActivityImpl.js" type="text/javascript" charset="utf-8"></script>
  <script src="js/ActivitiRest.js" type="text/javascript" charset="utf-8"></script>
  <script src="js/LineBreakMeasurer.js" type="text/javascript" charset="utf-8"></script>
  <script src="js/ProcessDiagramGenerator.js" type="text/javascript" charset="utf-8"></script>
  <script src="js/ProcessDiagramCanvas.js" type="text/javascript" charset="utf-8"></script>
  
  <style type="text/css" media="screen">
    
  </style>
</head>
<body>
<div class="wrapper">
  <div id="pb1"></div>
  <div id="overlayBox" >
    <div id="diagramBreadCrumbs" class="diagramBreadCrumbs" onmousedown="return false" onselectstart="return false"></div>
    <div id="diagramHolder" class="diagramHolder"></div>
    <div class="diagram-info" id="diagramInfo"></div>
  </div>
</div>
<script language='javascript'>
var DiagramGenerator = {};
var pb1;
$(document).ready(function(){
  var query_string = {};
  var query = window.location.search.substring(1);
  var vars = query.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
    query_string[pair[0]] = pair[1];
  } 
  var tasks={};
  tasks.userTask="用户任务";
  tasks.serviceTask="脚本任务";
  tasks.exclusiveGateway="互斥网关";
  tasks.parallelGateway="并行网关";
  tasks.inclusiveGateway="包容网关";
  tasks.startEvent="启动事件";
  tasks.endEvent="结束事件";
  
  
  var processDefinitionId = query_string["processDefinitionId"];
  var processInstanceId = query_string["processInstanceId"];
  
  console.log("Initialize progress bar");
  
  pb1 = new $.ProgressBar({
    boundingBox: '#pb1',
    label: 'Progressbar!',
    on: {
      complete: function() {
        console.log("Progress Bar COMPLETE");
        this.set('label', '加载完成!');
        if (processInstanceId) {
          ProcessDiagramGenerator.drawHighLights(processInstanceId);
        }
      },
      valueChange: function(e) {
        this.set('label', e.newVal + '%');
      }
    },
    value: 0
  });
  console.log("Progress bar inited");
  
  ProcessDiagramGenerator.options = {
    diagramBreadCrumbsId: "diagramBreadCrumbs",
    diagramHolderId: "diagramHolder",
    diagramInfoId: "diagramInfo",
    on: {
      click: function(canvas, element, contextObject){
        var mouseEvent = this;
        console.log("[CLICK] mouseEvent: %o, canvas: %o, clicked element: %o, contextObject: %o", mouseEvent, canvas, element, contextObject);

        if (contextObject.getProperty("type") == "callActivity") {
          var processDefinitonKey = contextObject.getProperty("processDefinitonKey");
          var processDefinitons = contextObject.getProperty("processDefinitons");
          var processDefiniton = processDefinitons[0];
          console.log("Load callActivity '" + processDefiniton.processDefinitionKey + "', contextObject: ", contextObject);

          // Load processDefinition
        ProcessDiagramGenerator.drawDiagram(processDefiniton.processDefinitionId);
        }
      },
      rightClick: function(canvas, element, contextObject){
        var mouseEvent = this;
        console.log("[RIGHTCLICK] mouseEvent: %o, canvas: %o, clicked element: %o, contextObject: %o", mouseEvent, canvas, element, contextObject);
      },
      over: function(canvas, element, contextObject){
        var mouseEvent = this;
        //console.log("[OVER] mouseEvent: %o, canvas: %o, clicked element: %o, contextObject: %o", mouseEvent, canvas, element, contextObject);

        // TODO: show tooltip-window with contextObject info
        ProcessDiagramGenerator.showActivityInfo(contextObject,tasks);
      },
      out: function(canvas, element, contextObject){
        var mouseEvent = this;
        //console.log("[OUT] mouseEvent: %o, canvas: %o, clicked element: %o, contextObject: %o", mouseEvent, canvas, element, contextObject);

        ProcessDiagramGenerator.hideInfo();
      }
    }
  };
  
  var baseUrl = window.document.location.protocol + "//" + window.document.location.host + "/";
  var shortenedUrl = window.document.location.href.replace(baseUrl, "");
  baseUrl = baseUrl + shortenedUrl.substring(0, shortenedUrl.indexOf("/"));
  
  ActivitiRest.options = {
    processInstanceHighLightsUrl: baseUrl + "/process-instance/{processInstanceId}/highlights?callback=?",
    processDefinitionUrl: baseUrl + "/process-definition/{processDefinitionId}/diagram-layout?callback=?",
    processDefinitionByKeyUrl: baseUrl + "/process-definition/{processDefinitionKey}/diagram-layout?callback=?"
  };
  
  if (processDefinitionId) {
    ProcessDiagramGenerator.drawDiagram(processDefinitionId);
    
  } else {
    alert("processDefinitionId parameter is required");
  }
});


</script>
</body>
</html>