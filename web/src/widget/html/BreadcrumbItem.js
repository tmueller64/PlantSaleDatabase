dojo.provide("dojo.widget.html.BreadcrumbItem");

/* HtmlBreadcrumbItem
 ***************/

dojo.widget.html.BreadcrumbItem = function(){
	dojo.widget.HtmlWidget.call(this);
}
dojo.inherits(dojo.widget.html.BreadcrumbItem, dojo.widget.HtmlWidget);

dojo.lang.extend(dojo.widget.html.BreadcrumbItem, {
	widgetType: "BreadcrumbItem",
	templateString: '<span dojoAttachEvent="onClick;"></span>',
	title: "",
        pane: "", // name of pane to show when this item is clicked
        link: null,
        sep: ">",

	fillInTemplate: function(args, frag){
		dojo.html.disableSelection(this.domNode);
                var c = document.createElement("span");
                c.appendChild(document.createTextNode(this.sep));
                dojo.html.addClass(c, "dojoBreadcrumbSeparator");
                this.domNode.appendChild(c);
                
                this.link = document.createElement("span");
                dojo.html.addClass(this.link, "dojoBreadcrumbItem");
		if(!dojo.string.isBlank(this.title)){
			this.link.appendChild(document.createTextNode(this.title));
		}else{
			this.link.appendChild(frag["dojo:"+this.widgetType.toLowerCase()]["nodeRef"]);
		}
                this.domNode.appendChild(this.link);
	},

        setSelectable: function() {
            dojo.html.addClass(this.link, "dojoBreadcrumbSelectableItem");
        },

        clearSelectable: function() {
            dojo.html.removeClass(this.link, "dojoBreadcrumbSelectableItem");
        },
	
	onClick: function(e){ this.onSelect(this, e); },
	
	// By default, when I am clicked, click the item inside of me
	onSelect: function (item, e) {
		var child = dojo.dom.getFirstChildElement(this.domNode);
		if(child){
			if(child.click){
				child.click();
			}else if(child.href){
				location.href = child.href;
			}
		}
	}
});

