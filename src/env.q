/other: ~,#_ !.   getenv exit
distinct:?:;group:=:;where:&:;flip:+:;type:@:;key:!:;til:{$[0>@x;!x;'`type]};value:get:.:;attr:-2!;cut:{$[0h>@x;x*!-_-(#y)%x;x]_y}
set:{$[@x;.[x;();:;y];-19!((,y),x)]};upsert:.[;();,;] / :: ,: files?
raze:,/;union:?,;inter:{x@&x in y};except:{x@&~x in y};cross:{n:#m:&(#x)##y;$[99h=@x;((!x)[m],'n#!y)!(. x)[m],'n#. y;((),x)[m],'n#y]} /extant:{x@&~^x}
sv:{x/:y};vs:{x\:y};sublist:{$[99h=@y;sublist[x;!y]!sublist[x;. y];~0h>@x;$[.Q.qp y;.Q.ind[y];y]i+!"j"$0|x[1]&(#y)-i:*x;abs[x]<#y;x#y;y]}
