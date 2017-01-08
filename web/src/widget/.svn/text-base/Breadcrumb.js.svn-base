dojo.provide("dojo.widget.Breadcrumb");
dojo.provide("dojo.widget.DomBreadcrumb");

dojo.require("dojo.widget.*");

dojo.widget.tags.addParseTreeHandler("dojo:breadcrumb");

/* Breadcrumb
 *******/

dojo.widget.Breadcrumb = function () {
	dojo.widget.Breadcrumb.superclass.constructor.call(this);
}
dojo.inherits(dojo.widget.Breadcrumb, dojo.widget.Widget);

dojo.lang.extend(dojo.widget.Breadcrumb, {
	widgetType: "Breadcrumb",
	isContainer: true,
	
	items: [],
	push: function(item){
		dojo.connect.event(item, "onSelect", this, "onSelect");
		this.items.push(item);
	},
	onSelect: function(){}
});


/* DomBreadcrumb
 **********/

dojo.widget.DomBreadcrumb = function(){
	dojo.widget.DomBreadcrumb.superclass.constructor.call(this);
}
dojo.inherits(dojo.widget.DomBreadcrumb, dojo.widget.DomWidget);

dojo.lang.extend(dojo.widget.DomBreadcrumb, {
	widgetType: "Breadcrumb",
	isContainer: true,

	push: function (item) {
		dojo.widget.Breadcrumb.call(this, item);
		this.domNode.appendChild(item.domNode);
	}
});

dojo.requireAfterIf("html", "dojo.widget.html.Breadcrumb");
