<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String basePath = request.getContextPath();
%>
<!doctype html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>资金流向</title>
		<style>
	    	pre {
	    		padding: 60px 0 0 30px;color: gray;font-size: .8em;line-height: 20px;
	    	}
	    </style>
		<script src="<%=basePath%>/libs/loading.js" type="text/javascript"></script>
        <script src="<%=basePath%>/libs/ajax.js" type="text/javascript"></script>
	</head>
<body>
	<canvas id="canvas" width="200" height="200" style="border:1px solid #69c"></canvas>
	<script type="text/javascript">       
        //持仓比例图
        function moneyFlowPainter(canvasId, options) {
            this.canvas = document.getElementById(canvasId);
            var canvas = this.canvas;
            if (this.canvas && this.canvas.getContext) {
                var ctx = this.canvas.getContext('2d');                
                var rate = options.rate;
                var rotateTo = Math.PI * 4 / 5 * rate / 100;
                var rotateStep = rotateTo / 60;
                var me = this;
                var currentRotate = rotateStep;
                me.intervalHandler = setInterval(function () {
                    ctx.save();
                    //现在center是原点
                    var radius = options.radius || Math.min(canvas.width, canvas.height) / 2;
                    var center = options.center || { x: canvas.width/2, y: canvas.height/2 };
                    ctx.translate(center.x, center.y);
                    center = { x: 0, y: 0 };
                    //画出背景
                    var startAngle = Math.PI * 1.4;
                    var endAngle = startAngle + Math.PI / 5;

                    //顶部扇形区域
                    ctx.beginPath();
                    ctx.moveTo(center.x, center.y);
                    ctx.arc(center.x, center.y, radius, startAngle, endAngle);
                    ctx.closePath();
                    var color = options.normalColor || 'rgb(255,204,51)'; ;
                    ctx.fillStyle = color;
                    ctx.fill();

                    //大量流入扇形区
                    ctx.shadowColor = "lightgray";
                    ctx.shadowBlur = 5;
                    ctx.shadowOffsetX = 3;
                    ctx.shadowOffsetY = 3;
                    startAngle = endAngle;
                    endAngle += Math.PI / 10 * 7;
                    color = 'rgb(204,51,51)';
                    ctx.beginPath();
                    ctx.moveTo(center.x, center.y);
                    ctx.arc(center.x, center.y, radius, startAngle, endAngle);
                    ctx.closePath();
                    ctx.fillStyle = color;
                    ctx.fill();

                    //大量流出扇形区
                    ctx.shadowColor = null;
                    ctx.shadowBlur = 0;
                    ctx.shadowOffsetX = 0;
                    ctx.shadowOffsetY = 0;

                    startAngle = Math.PI / 10 * 7;
                    endAngle = Math.PI * 1.4;
                    color = 'rgb(0,153,51)'; //'green';
                    ctx.beginPath();
                    ctx.moveTo(center.x, center.y);
                    ctx.arc(center.x, center.y, radius, startAngle, endAngle);
                    ctx.closePath();
                    ctx.shadowOffsetX = 0;
                    ctx.fillStyle = color;
                    ctx.fill();

                    //画白线
                    var step = Math.PI * .1;
                    var start = Math.PI * .7;
                    var end = Math.PI * 2.3;

                    for (; start < end; start += step) {
                        ctx.beginPath();
                        ctx.moveTo(center.x, center.y);
                        ctx.lineTo(center.x + radius * Math.cos(start), center.y + radius * Math.sin(start));
                        ctx.strokeStyle = 'white';
                        ctx.lineWidth = 1;
                        ctx.closePath();
                        ctx.stroke();
                    }

                    //画百分比文字
                    var textPoint = { x: 0, y: radius / 2 };
                    ctx.fillStyle = options.fontColor || 'black';
                    ctx.font = options.font || '12px Arial';
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'middle';
                    ctx.fillText(rate + '%', textPoint.x, textPoint.y);
                    //画指针
                    ctx.rotate(currentRotate);
                    ctx.moveTo(0, 0);
                    ctx.lineTo(-3, -3);
                    ctx.lineTo(0, 0 - radius);
                    ctx.lineTo(3, -3);
                    ctx.closePath();
                    ctx.strokeStyle = 'gray';
                    ctx.fillStyle = '#333333';
                    ctx.stroke();
                    ctx.fill();

                    ctx.restore();
                    var wiseClock = rotateStep > 0;

                    if (wiseClock) {
                        if (currentRotate < rotateTo) currentRotate += rotateStep;
                        else clearInterval(me.intervalHandler);
                    } else {
                        if (currentRotate > rotateTo) currentRotate += rotateStep;
                        else clearInterval(me.intervalHandler);
                    }
                }, 20);
            }
        }
        var dataUrl = 'moneyFlow.xml';
        Ajax.get(dataUrl,function(client){
	        var xml = client.responseXML;
	        var rate = xml.getElementsByTagName('Item')[0].getElementsByTagName('Item')[0].getAttribute('rate');
	        var painter = new moneyFlowPainter('canvas', { rate: rate, font: '12px Arial', fontColor: (rate>0?'red':(rate==0?'black':'green')), radius: 60 });
        },'canvas',true);
        //var rate = 50;
        //var painter = new moneyFlowPainter('canvas', { rate: rate, font: '12px Arial', fontColor: (rate > 0 ? 'red' : (rate == 0 ? 'black' : 'green')), radius: 60 });
    </script>
	<p><a href="<%=basePath%>/index.jsp">返回列表页</a></p>
</body>
</html>