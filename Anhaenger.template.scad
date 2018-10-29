// scripts must generate string like the following:
//texts = ["abcdefg", "hijklmnop", "more text", "and even more text", "on last longer text"];

///////////
fontheight = 1;
font="Inconsolata:style=Bold";

blockX=80;
blockY=12;
blockZ=2;


fontextrude=fontheight+blockZ;


// max 27 letters
function getfontsize(lettercount) =
    lettercount <= 16 ? 8 :
    lettercount <= 18 ? 7 :
    lettercount <= 20 ? 6 :
    lettercount <= 23 ? 5 : 4;

function getblockX(lettercount) = 
    lettercount <= 16 ? 5.5*lettercount :
    lettercount <= 18 ? 4.9*lettercount :
    lettercount <= 20 ? 4.2*lettercount :
    lettercount <= 23 ? 3.5*lettercount :
    2.75*lettercount;

module mylabel(l) {
    linear_extrude(height=fontextrude) {
        text(l,
        size=getfontsize(len(l)), font=font, spacing=1.0,
        valign = "center", $fn = 16);
    }
}



module anhaenger(txt, txtlen, pos) {
    color("SkyBlue") union() {
        translate ([0, pos, 0]) mylabel(txt);
        translate ([0, pos, 0]) difference () {
            union() {
                translate([-blockY/2, -blockY/2, 0]) 
                    cube([getblockX(txtlen)+blockY/2,blockY,blockZ]);
                translate([-blockY/2, 0, 0]) 
                    cylinder(h=fontheight+blockZ, r1=blockY/2,r2=blockY/2, $fn=32);
            }
            translate([-blockY/2, 0, -0.1])
                cylinder(h=fontheight+blockZ+.2, r1=3,r2=3, $fn=32);
        }
    }
}

for (i=[0:len(texts)-1]) {
    echo(texts[i],i,len(texts[i]));
    anhaenger(texts[i], len(texts[i]), i*20);
}

