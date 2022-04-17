/each: +-*%&|^<>=$ <= >= <> @ ? in within bin div abs log exp sqrt sin cos tan  f' f\: f/:
neg:-:;not:~:;null:^:;string:$:;reciprocal:%:;floor:_:;ceiling:-_-:;signum:{(x>0)-x<0}
mod:{x-y*x div y};xbar:{x*y div x:$[16h=abs[@x];"j"$x;x]};xlog:{log[y]%log x};and:&;or:|;each:{x'y};scan:{x\y};over:{x/y};prior:{x':y}
mmu:$;lsq:!;inv:!:;md5:-15!;ltime:%:;gtime:{t+x-%t:x+x-%x}; /xnull:{$[0>@y;(,y)@~x=y;x=y;y 0N;y]}

/aggr: last sum prd min max avg wsum wavg f/   /beta:{cov[x;y]%var x}
count:#:;first:*:;svar:{(n*var x)%-1+n:(#x)-+/^x};sdev:{sqrt svar x};scov:{(n*cov[x;y])%-1+n:(#x)-+/^x+y};med:{avg x(<x)@_.5*-1 0+#x,:()};all:min"b"$;any:max"b"$;rand:{*1?x}

/unif: f': f\
sums:+\;prds:*\;mins:&\;maxs:|\;fills:^\;deltas:-':;ratios:%':;avgs:{(+\x)%+\~^x};differ:"b"$~~':;prev: :':;next:{$[0h>@x;'`rank;1_x,,x 0N]};
rank:{$[0h>@x;'`rank;<<x]};reverse:|:;iasc:{$[0h>@x;'`rank;<x]};idesc:{$[0h>@x;'`rank;>x]}
asc:{$[99h=@x;(!x)[i]!`s#r i:<r:. x;`s=-2!x;x;0h>@x;'`rank;`s#x@<x]};desc:{$[99h=@x;(!x)[i]!r i:>r:. x;0h>@x;'`rank;x@>x]}

msum:{$[99h=@y;(!y)!.z.s[x;. y];y-(-x)_(0i*x#y),y:+\y]};mcount:{msum[x;~^y]};mavg:{msum[x;0.0^y]%mcount[x;y]};mdev:{sqrt mavg[x;y*y]-m*m:mavg[x;y:"f"$y]}
xrank:{$[0h>@y;'`rank;_y*x%#y:<<y]};mmin:{(x-1)&':/y};mmax:{(x-1)|':/y};xprev:{$[0h>@y;'`rank;y(!#y)-x]};rotate:{$[0h>@y;'`rank;98h<@y;'`type;#y;,/|(0;mod[x;#y])_y;y]};ema:{(*y)(1f-x)\x*y}

/other: ~,#_ !.   getenv exit
distinct:?:;group:=:;where:&:;flip:+:;type:@:;key:!:;til:{$[0>@x;!x;'`type]};value:get:.:;attr:-2!;cut:{$[0h>@x;x*!-_-(#y)%x;x]_y}
set:{$[@x;.[x;();:;y];-19!((,y),x)]};upsert:.[;();,;] / :: ,: files?
raze:,/;union:?,;inter:{x@&x in y};except:{x@&~x in y};cross:{n:#m:&(#x)##y;$[99h=@x;((!x)[m],'n#!y)!(. x)[m],'n#. y;((),x)[m],'n#y]} /extant:{x@&~^x}
sv:{x/:y};vs:{x\:y};sublist:{$[99h=@y;sublist[x;!y]!sublist[x;. y];~0h>@x;$[.Q.qp y;.Q.ind[y];y]i+!"j"$0|x[1]&(#y)-i:*x;abs[x]<#y;x#y;y]}

/file&comm
read0:0::;read1:1::;hclose:>:;hdel:~:;hsym:"s"$-1!';hcount:-7!;peach:{x':y};system:."\\",

/string:  like ss
ltrim:{$[~t&77h>t:@x;.z.s'x;^*x;((^x)?0b)_x;x]};rtrim:{$[~t&77h>t:@x;.z.s'x;^last x;(-(|^x)?0b)_x;x]};trim:{ltrim rtrim x}
lower:{$[$[(~@x)&10h~@*x;&/10h=@:'x;0b];_x;~t&77h>t:abs@@x;.z.s'x;19<t;.z.s@. x;~t in 10 11h;'`type;_x]}
upper:{$[$[(~@x)&10h~@*x;&/10h=@:'x;0b];.Q.Aa x;~t&77h>t:abs@@x;.z.s'x;19<t;.z.s@. x;~t in 10 11h;'`type;$[11=t;`$.Q.Aa@$x;.Q.Aa x]]}
ssr:{,/@[x;1+2*!_.5*#x:(0,/(0,{n:x?"[";$[n=#x;n;n+.z.s$[(#x)=p:x?"]";'"unmatched ]";p]_x:(n+2+"^"=x n+1)_x]}y,"")+/:x ss y)_x;$[100h>@z;:[;z];z]]}

/select insert update delete exec  / fkeys[&keys] should be eponymous, e.g. order.customer.nation   
/{keys|cols}`t `f's{xasc|xdesc}`t n!`t xcol(prename) xcols(prearrange)  FT(xcol xasc xdesc)
view:{(2+*x ss"::")_x:*|*|.`. .`\:x};tables:{."\\a ",$$[^x;`;x]};views:{."\\b ",$$[^x;`;x]}
cols:{$[.Q.qp x:.Q.v x;.Q.pf,!+x;98h=@x;!+x;11h=@!x;!x;!+0!x]} /cols:{!.Q.V x}
xcols:{(x,f@&~(f:cols y)in x)#y};keys:{$[98h=@x:.Q.v x;0#`;!+!x]};xkey:{(#x)!.[0!y;();xcols x]};
xcol:{.Q.ft[{+$[99h=@x;@[!y;(!y)?!x;:;. x];x,(#x)_!y]!. y:+y}x]y};xasc:{$[$[#x;~`s=-2!(0!.Q.v y)x;0];.Q.ft[@[;*x;`s#]].Q.ord[<:;x]y;y]};xdesc:{$[#x;.Q.ord[>:;x]y;y]}
fkeys:{(&~^x)#x:.Q.fk'.Q.V x};meta:{([!c].Q.ty't;f:.Q.fk't;a:-2!'t:. c:.Q.V x)}

/ R uj R(union join) R lj K(left(equi/asof)join)   trade asof`sym`time!(`IBM;09:31:00.0)
lj:{$[$[99h=@y;(98h=@!y)&98h=@. y;()~y];.Q.ft[,\:[;y];x];'"type"]} /;la:{$[&/j:z>-1;x,'y z;+.[+ff[x]y;(!+y;j);:;.+y z j:&j]]}{la[x;. y](!y)?(!+!y)#x}[;y]]x} /lj:,\:;aj:{lj[y]`s#xkey[x]z};aj0:{lj[y]`s#(x#z)!z}; /;bn:{@[i;&0>i:x bin y;:;#x]}
ljf:{$[`s=-2!y;ajf[!+!y;x;0!y];.Q.ft[{$[&/j:(#y:. y)>i?:(!+i:!y)#x;.Q.fl[x]y i;+.[+x;(f;j);:;.+.Q.fl[((f:!+y)#x:.Q.ff[x]y)j]y i j:&j]]}[;y]]x]}
.Q.ajf0:{[f;g;x;y;z]x,:();z:0!z;d:$[g;x_z;z];g:(:;^)f;f:(,;^)f;$[&/j:-1<i:(x#z)bin x#y;f'[y;d i];+.[+.Q.ff[y]d;(!+d;j);g;.+d i j:&j]]}
aj:{.Q.ft[.Q.ajf0[0;1;x;;z]]y};aj0:{.Q.ft[.Q.ajf0[0;0;x;;z]]y};ajf:{.Q.ft[.Q.ajf0[1;1;x;;z]]y};ajf0:{.Q.ft[.Q.ajf0[1;0;x;;z]]y}
ij:{.Q.ft[{x[j],'(. y)i j:&(#y)>i:(!y)?(!+!y)#x}[;y]]x}
ijf:{.Q.ft[{.Q.fl[x j]y i j:&(#y:. y)>i?:(!+i:!y)#x}[;y]]x}
pj:{.Q.ft[{x+0i^y(!+!y)#x}[;y]]x};asof:{f:!$[99h=@y;y;+y];(f_x)(f#x)bin y}
uj:{$[()~x;y;()~y;x;98h=@x;x,(!+x:.Q.ff[x;y])#.Q.ff[y;x];lj[(?(!x),!y)#x]y]}
ujf:{$[()~x;y;98h=@x;x,(!+x:.Q.ff[x;y])#.Q.ff[y;x];ljf[(?(!x),!y)#x]y]}

/wj[-1000 2000+\:trade`time;`sym`time;trade;(quote;(max;`ask);(min;`bid))]  (given `sym`time xasc quote)
ww:{[a;w;f;y;z]f,:();e:1_z;z:*z;y,'n#+(:/'f)!+{[e;d;a;b]e .'d@\:\:a+!b-a}[*:'e;z f:1_'e]/'$[n:#*w;+$[#g;(g#z)?g#y;0]|/:a+$[#g:-1_f;(f#z)bin@[f#y;*|f;:;]@;z[*f]bin]'w;,0 0]}
wj:{[w;f;y;z]ww[0 1;w;f;y;z]};wj1:{[w;f;y;z]ww[1;w-1 0;f;y;z]}

fby:{$[(#x 1)=#y;@[(#y)#x[0]0#x 1;g;:;x[0]'x[1]g:.=y];'`length]};xgroup:{x,:();a:x#y:0!y;$[#x_:y;+:'x@=a;a!+f!(#f:!+x)#()]};ungroup:{$[#x:0!x;,/+:'x;x]}
ej:{x,:();y[&#:'i],'(x_z)(!0),/i:(=x#z:0!z)x#y:0!y} /{ungroup lj[z]xgroup[x]y}

/`[:../]t[.{csv|txt}]
save:{$[1=#p:`\:*|`\:x:-1!x;set[x;. *p];   x 0:.h.tx[p 1]@.*p]}'
load:{$[1=#p:`\:*|`\:x:-1!x;set[*p;. x];set[*p].h.xt[p 1]@0:x]}'
rsave:{x:-1!x;.[`/:x,`;();:;.*|`\:x]}'
rload:{x:-1!x;.[*|`\:x;();:;.     x]}'
dsave:{.[*x;1_x,y,`;:;@[;*!+a;`p#].Q.en[*x]a:. y];y}/: 

show:{1 .Q.s x;};csv:"," / ";"  also \z 1 for "D"$"dd/mm/yyyy"

parse:{$["\\"=*x;(system;1_x);-5!x]};eval:-6!;reval:-24!
\d .Q  /def[`a`b`c!(0;0#0;`)]`b`c!(("23";"24");,"qwe")
k:4.0;K:2020.05.04;host:-12!;addr:-13!;gc:-20!;ts:{-34!(x;y)};gz:-35!;w:{`used`heap`peak`wmax`mmap`mphy`syms`symw!(."\\w"),."\\w 0"}  / used: dpft en par chk ind fs fu fc
res:`abs`acos`asin`atan`avg`bin`binr`cor`cos`cov`delete`dev`div`do`enlist`exec`exit`exp`getenv`hopen`if`in`insert`last`like`log`max`min`prd`select`setenv`sin`sqrt`ss`sum`tan`update`var`wavg`while`within`wsum`xexp
addmonths:{("d"$m+y)+x-"d"$m:"m"$x}
Xf:{y 1:0xfe20,("x"$77+@x$()),13#0x00;(`$($y),"#")1:0x};Cf:Xf`char
f:{$[^y;"";y<0;"-",f[x;-y];y<1;1_f[x;10+y];9e15>j:"j"$y*prd x#10f;(x_j),".",(x:-x)#j:$j;$y]}
fmt:{$[x<#y:f[y;z];x#"*";(-x)$y]}