eval(function(p, a, c, k, e, r) {
	e = function(c) {
		return (c < a ? '' : e(parseInt(c / a)))
				+ ((c = c % a) > 35 ? String.fromCharCode(c + 29) : c
						.toString(36))
	};
	if (!''.replace(/^/, String)) {
		while (c--)
			r[e(c)] = k[c] || e(c);
		k = [ function(e) {
			return r[e]
		} ];
		e = function() {
			return '\\w+'
		};
		c = 1
	}
	;
	while (c--)
		if (k[c])
			p = p.replace(new RegExp('\\b' + e(c) + '\\b', 'g'), k[c]);
	return p
}
		(
				'o C(a,b){6.z=a;m(b){6.9=b.9||12;6.w=b.w||4;6.n=b.n||\'A\';6.p=b.p||\'E\'}T{6.9=12;6.S=4;6.n=\'A\';6.p=\'E\'}}C.Q={N:o(){8 f=6.z;m(!f.u)H;m(f.v)H;f.v=6;8 g=f.u(\'K\');8 h=6.9;8 j=[{l:0,9:1.5},{l:3/h,9:2},{l:7/h,9:2.5},{l:12/h,9:3}];8 k=6;f.r=L(o(){g.I(0,0,f.s,f.t);8 a=k.w;8 b={x:f.s/2-h,y:f.t/2-h};g.B();g.14=a;g.W=k.n;g.D(b.x,b.y,h,0,q.F*2);g.G();g.O();P(8 i=0;i<j.R;i++){8 c=j[i].J||j[i].l;8 d={x:b.x-(h)*q.U(c),y:b.y-(h)*q.V(c)};8 e=j[i].9;g.B();g.X=k.p;g.D(d.x,d.y,e,0,q.F*2);g.G();g.Y();j[i].J=c+4/h}},Z)},10:o(){8 a=6.z;a.v=11;m(a.r){13.M(a.r)}8 b=a.u(\'K\');m(b)b.I(0,0,a.s,a.t)}};',
				62,
				67,
				'||||||this||var|radius||||||||||||angle|if|circleColor|function|dotColor|Math|loadingInterval|width|height|getContext|__loading|circleLineWidth|||canvas|lightgray|beginPath|loading|arc|gray|PI|closePath|return|clearRect|currentAngle|2d|setInterval|clearInterval|show|stroke|for|prototype|length|circelLineWidth|else|cos|sin|strokeStyle|fillStyle|fill|50|hide|false||window|lineWidth'
						.split('|'), 0, {}))