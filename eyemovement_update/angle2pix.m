function n=angle2pix(prefs,ang)
n=2*prefs.dist*tan(ang*pi/360)/prefs.pixelSize;
end
