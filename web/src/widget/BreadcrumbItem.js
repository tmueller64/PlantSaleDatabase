dojo.provide("dojo.widget.BreadcrumbItem");
dojo.provide("dojo.widget.DomBreadcrumbItem");

dojo.require("dojo.string");
dojo.require("dojo.widget.*");

dojo.widget.tags.addParseTreeHandler("dojo:breadcrumbitem");

/* BreadcrumbItem
 ***********/
 
dojo.widget.BreadcrumbItem = function(){
	dojo.widget.BreadcrumbItem.superclass.constructor.call(this);
}
dojo.inherits(dojo.widget.BreadcrumbItem, dojo.widget.Widget);

dojo.lang.extend(dojo.widget.BreadcrumbItem, {
	widgetType: "BreadcrumbItem",
	isContainer: true
});


/* DomBreadcrumbItem
 **************/
dojo.widget.DomBreadcrumbItem = function(){
	dojo.widget.DomBreadcrumbItem.superclass.constructor.call(this);
}
dojo.inherits(dojo.widget.DomBreadcrumbItem, dojo.widget.DomWidget);

dojo.lang.extend(dojo.widget.DomBreadcrumbItem, {
	widgetType: "BreadcrumbItem"
});

dojo.requireAfterIf("html", "dojo.html");
dojo.requireAfterIf("html", "dojo.widget.html.BreadcrumbItem");
