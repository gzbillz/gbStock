<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
	String basePath = request.getContextPath();
%>
<!doctype html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>成交金额分析</title>
		<style>
    		pre{
    			padding: 60px 0 0 30px;
    			color: gray;
    			font-size: .8em;
    			line-height: 20px;
    		}
    	</style>
		<script src="<%=basePath%>/libs/ajax.js" type="text/javascript"></script>
	    <script src="<%=basePath%>/libs/xmlparser.js" type="text/javascript"></script>
	    <script src="<%=basePath%>/libs/loading.js" type="text/javascript"></script>
	    <script src="<%=basePath%>/libs/absPainter.js" type="text/javascript"></script>
	    <script src="<%=basePath%>/libs/util.js" type="text/javascript"></script>
	    <script src="<%=basePath%>/libs/axis-x.js" type="text/javascript"></script>
	    <script src="<%=basePath%>/libs/axis-y.js" type="text/javascript"></script>
	    <script src="<%=basePath%>/libs/crossLines.js" type="text/javascript" charset="GBK"></script>
	    <script src="<%=basePath%>/libs/tip.js" type="text/javascript" charset="GBK"></script>
	    <script src="<%=basePath%>/libs/chartEventHelper.js" type="text/javascript"></script>
	    <script src="<%=basePath%>/libs/linepainter.js" type="text/javascript"></script>
	</head>
<body>
	<canvas id="canvas" width="500" height="400" style="border: 1px solid lightgray">
    </canvas>
        <script type="text/javascript">
/*
html5行情图库
*/
        //http://vol.stock.hexun.com/Charts/Now/Share/info1.ashx?code=600036
        //http://vol.stock.hexun.com/600036.shtm
        /**
        data format:
        var data = {
        title:'招商银行(600036)成交金额分析',
        stock:'招商银行',
        preClose:11.70,
        flowUnit:'万元',
        items: [{ time: '09:30', price: 11.64, flowIn: 49.27, flowOut: 10.87}]
        };*/
        var canvasId = 'canvas';
        var options = {
            region: { x: 60, y: 50, width: 400, height: 320, borderColor: 'lightgray' },
            minsCount: 241,
            bar: { width: 1, flowInColor: 'red', flowOutColor: 'green' },
            priceLineColor: '#6699cc',
            priceColors:{rise:'red',fall:'green',normal:'black'},
            titleOptions:{font:'Bold 11px 宋体',position:{x:15,y:5},color:'black',textBaseline:'top'},
            flowUnitOptions:{font:'11px 宋体',position:{x:30,y:28},color:'black',textBaseline:'top'},
            stockNameOptions:{font:'11px 宋体',position:{x:400,y:28},color:'black',textBaseline:'top'},
            xAxis: { font: '11px Arial', region: { x: 60, y: 373, height: 30, width: 400 }, color: 'black',textBaseline:'top' },
            yAxisFlow: { font: '11px Arial', region: { x: 0, y: 47, height: 320, width: 55}, color: 'black',align:'right' ,fontHeight:8,textBaseline:'top'},
            yAxisPrice: { font: '11px Arial', region: { x: 462, y: 47, height: 320, width: 48}, color: 'black',align:'left' ,fontHeight:8,textBaseline:'top'}
        };

        
        var implementFlowInOut = {
            start: function () {
                //画框和线
                var ctx = this.ctx;
                var region = options.region;
                ctx.beginPath();
                ctx.strokeStyle = region.borderColor;
                ctx.rect(region.x, region.y, region.width, region.height);
                ctx.closePath();
                ctx.stroke();

                function fillText(txt,ops){
                  if(ops){
                    ctx.fillStyle = ops.color;
                    ctx.font = ops.font;
                    if(ops.textBaseline) ctx.textBaseline = ops.textBaseline;
                    ctx.fillText(txt,ops.position.x,ops.position.y);
                  }
                }
                fillText(this.data.title,options.titleOptions);
                fillText('('+this.data.flowUnit+')',options.flowUnitOptions);
                fillText(this.data.stock,options.stockNameOptions);
                ctx.save();
                //转换坐标
                ctx.translate(region.x, region.y + region.height / 2);

                //画线
                var hlines = new Array();
                hlines[0] = 0;
                hlines[1] = region.height / 6;
                hlines[2] = region.height * 2 / 6;
                hlines[3] = 0 - region.height / 6;
                hlines[4] = 0 - region.height * 2 / 6; 
                var me = this;
                hlines.each(function (i) {
                    me.drawHLine(region.borderColor, 0, i, region.width);
                });

                var vlines =new Array();
                vlines[0] = region.width / 4;
                vlines[1] = region.width / 2;
                vlines[2] = region.width * 3 / 4;
                vlines.each(function (i) {
                    me.drawVLine(region.borderColor, i, 0 - region.height / 2, region.height);
                });

                //this.drawHLine(options.region.borderColor, 0, 0, region.width);

                //获得最大值
                maxFlow = 0;
                this.data.items.each(function (item) {
                    var maxI = Math.max(item.flowIn, item.flowOut);
                    maxFlow = Math.max(maxI, maxFlow);
                });
                this.maxFlow = maxFlow;
            },
            getDataLength: function () { return this.data.items.length; },
            getX: function (i) {
                return (i + 1) * (options.region.width / options.minsCount);
            },
            paintItem: function (i, x, y) {
                var ctx = this.ctx;
                ctx.beginPath();
                var y = this.data.items[i].flowIn / this.maxFlow * options.region.height / 2;
                ctx.rect(x, 0 - y, options.bar.width, y);
                ctx.fillStyle = options.bar.flowInColor;
                ctx.fill();

                ctx.beginPath();
                var y = this.data.items[i].flowOut / this.maxFlow * options.region.height / 2;
                ctx.rect(x, 0, options.bar.width, y);
                ctx.fillStyle = options.bar.flowOutColor;
                ctx.fill();
            },
            end: function () {
                this.ctx.restore();
            }
        };

        Ajax.get('dealAmountAnalysis.xml', function (client) { 
            var doc = client.responseXML;
            var parser = new XmlParser(doc);
            var data = {
                title: parser.getValue('Data/Title/@name'),
                stock: parser.getValue('Data/Item[1]/Title/@name'),
                preClose: parser.getValue('Data/Item[1]/Title/@close'),
                flowUnit: parser.getValue('Data/Item[0]/Title/@unit')
                //items: [{ time: '09:30', price: 11.64, flowIn: 49.27, flowOut: 10.87}]
            };

            var items = new Array();
            var itemsNodes = parser.getNodes('Data/Item[0]/Item');
            var priceNodes = parser.getNodes('Data/Item[1]/Item');

            for (var i = 0; i < itemsNodes.length; i++) {
                var node = itemsNodes[i];
                var time = node.getAttribute('date');
                if (time < '09:30') continue;
                var index = items.length;
                items[index] = {
                    time: time,
                    flowIn: parseFloat(node.getAttribute('inflow')),
                    flowOut: parseFloat(node.getAttribute('outflow'))
                };
            }
            function getTimeByIndex(i) {
                if (i <= 120) {
                    i += 30;
                    var minutes = i % 60;
                    var hour = 9 + (i - minutes) / 60;
                    if (hour < 10) hour = '0' + hour;
                    if (minutes < 10) minutes = '0' + minutes;
                    return hour + ':' + minutes;
                } else {
                    i = i - 121;
                    var minutes = i % 60;
                    var hour = 13 + (i - minutes) / 60;
                    if (minutes < 10) minutes = '0' + minutes;
                    return hour + ':' + minutes;
                }
            }
            for (var i = 0; i < priceNodes.length; i++) {
                if (i < items.length) items[i].price = priceNodes[i].getAttribute('price');
                else items[items.length] = { time: getTimeByIndex(i), price: priceNodes[i].getAttribute('price'), flowIn: 0, flowOut: 0 };
            }

            data.items = items;

            var painterFlow = new Painter(canvasId, implementFlowInOut, data);
            painterFlow.paint();
            var priceLinePainter = new linePainter({
                region: options.region,
                maxDotsCount: options.minsCount,
                getDataLength: function () { return this.data.items.length; },
                getItemValue: function (item) { return item.price; },
                middleValue: parseFloat(data.preClose), //通常是昨收
                lineColor:options.priceLineColor
            });
            var paintPrice = new Painter(canvasId, priceLinePainter, data);
            paintPrice.paint();

            //价格坐标轴
            var preClose = parseFloat(data.preClose);
            var canvas = $id(canvasId);
            function getIndexByX(x) {
                var index = Math.ceil((x - options.region.x) * options.minsCount / options.region.width);
                if (index > items.length - 1) index = items.length - 1;
                return index;
            }
            addCrossLinesAndTipEvents(canvas, {
                getCrossPoint: function (ev) {
                    ev = ev || event;
                    getOffset(ev);
                    var dataIndex = getIndexByX(ev.offsetX);
                    var x = options.region.x + priceLinePainter.getX.call(paintPrice, dataIndex);
                    return { x: x, y: ev.offsetY };
                },
                triggerEventRanges: { x: options.region.x, y: options.region.y, width: options.region.width, height: options.region.height },
                tipOptions: {
                    getTipHtml: function (ev) {
                        ev = ev || event;
                        getOffset(ev);
                        var dataIndex = getIndexByX(ev.offsetX);
                        if (dataIndex >= 0 && dataIndex < items.length) {
                            var dataItem = items[dataIndex];
                            //{ time: '09:30', price: 11.64, flowIn: 49.27, flowOut: 10.87}
                            return '时　　间：' + dataItem.time
                                + '<br/>流入资金：<font color="' + options.priceColors.rise + '">' + dataItem.flowIn + '(' + data.flowUnit + ')</font>'
                                + '<br/>流出资金：<font color="' + options.priceColors.fall + '">' + dataItem.flowOut + '(' + data.flowUnit + ')</font>'
                                + '<br/>价　　格：<font color="' + (dataItem.price > preClose ? options.priceColors.rise : options.priceColors.fall) + '">'
                                + parseFloat(dataItem.price).toFixed(2) + '</font>';
                        }
                    },
                    position: { x: false, y: options.region.y + options.region.height / 5 }, //position中的值是相对于canvas的左上角的
                    size: { width: 150, height: 80 },
                    opacity: 80,
                    cssClass: null,
                    offsetToPoint: 30
                },
                crossLineOptions: {
                    color: 'black'
                }
            });

            //时间轴
            var xAxisImple = new xAxis(options.xAxis);
            var xAxisPainter = new Painter(canvasId, xAxisImple, ['09:30', '10:30', '11:00/13:00', '14:00', '15:00']);
            xAxisPainter.options = xAxisImple.options;
            xAxisPainter.paint();

            var scalers = [];
            scalers.push(painterFlow.maxFlow.toFixed(2));
            scalers.push((painterFlow.maxFlow * 2 / 3).toFixed(2));
            scalers.push((painterFlow.maxFlow / 3).toFixed(2));
            scalers.push(0);
            scalers.push('-' + (painterFlow.maxFlow / 3).toFixed(2));
            scalers.push('-' + (painterFlow.maxFlow * 2 / 3).toFixed(2));
            scalers.push('-' + painterFlow.maxFlow.toFixed(2));

            //资金流向坐标轴
            var flowScalerImpl = new yAxis(options.yAxisFlow);
            var yAxisPainterFlow = new Painter(canvasId, flowScalerImpl, scalers);
            yAxisPainterFlow.scalerOptions = options.yAxisFlow;
            yAxisPainterFlow.paint();

            var diffMax = parseFloat(paintPrice.maxDiff);
            var max = preClose + diffMax;
            var priceScalers = new Array();
            var step = diffMax / 3;
            for (var i = 0; i < 7; i++) {
                priceScalers.push((max - i * step).toFixed(2));
            }
            options.yAxisPrice.color = function (val) {
                if (parseFloat(val) > preClose) return options.priceColors.rise;
                else if (parseFloat(val) == preClose) return options.priceColors.normal;
                return options.priceColors.fall;
            };
            var priceScalerImpl = new yAxis(options.yAxisPrice);
            var yAxisPainterPrice = new Painter(canvasId, priceScalerImpl, priceScalers);
            yAxisPainterPrice.scalerOptions = options.yAxisPrice;
            yAxisPainterPrice.paint();
        }, canvasId, true);
    </script>
    <p><a href="<%=basePath%>/index.jsp">返回列表页</a></p>
</body>
</html>