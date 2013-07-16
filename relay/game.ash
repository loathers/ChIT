
/*  Original game.php code for KoL

<html><head><title>The Kingdom of Loathing</title><script language="Javascript" src="/basics.js"></script><link rel="stylesheet" href="/basics.css" /></head>
<frameset id=rootset cols="4*,*">
  <frameset id=menuset rows="50,*">
    <frame name=menupane src="topmenu.php" scrolling=no></frame>
    <frameset id=mainset cols="200,*">
      <frame name=charpane src="charpane.php"></frame>
      <frame name=mainpane src="main.php"></frame>
    </frameset>
  </frameset>
  <frame name=chatpane src="chatlaunch.php"></frame>
</frameset>
<script src="/onfocus.js"></script></html>

*/

// Rewritten game.php by bordemstirs
void main(){
 writeln('<html><head><title>The Kingdom of Loathing</title><script language="Javascript" src="/basics.js"></script><link rel="stylesheet" href="/basics.css" /></head>');
 writeln('<frameset id=rootset cols="200,3*,*">');
 writeln('  <frame name=charpane src="charpane.php"></frame>');
 writeln('  <frameset id=mainset rows="50,*">');
 writeln('    <frame name=menupane src="topmenu.php" scrolling=no></frame>');
 writeln('    <frame name=mainpane src="main.php"></frame>');
 writeln('  </frameset>');
 writeln('  <frame name=chatpane src="chatlaunch.php"></frame>');
 writeln('</frameset>');
 writeln('<script src="/onfocus.js"></script></html>');
}
