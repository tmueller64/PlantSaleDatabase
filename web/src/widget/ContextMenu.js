dojo.provide("dojo.widget.ContextMenu");

dojo.require("dojo.widget.*");
dojo.require("dojo.widget.DomWidget");

dojo.widget.ContextMenu = function(){
	dojo.widget.Widget.call(this);
	this.widgetType = "ContextMenu";
	this.isContainer = true;
	this.isOpened = false;
	
	// copy children widgets output directly to parent (this node), to avoid
	// errors trying to insert an <li> under a <div>
	this.snarfChildDomOutput = true;

}

dojo.inherits(dojo.widget.ContextMenu, dojo.widget.Widget);
dojo.widget.tags.addParseTreeHandler("dojo:contextmenu");

dojo.requireAfterIf("html", "dojo.widget.html.ContextMenu");
