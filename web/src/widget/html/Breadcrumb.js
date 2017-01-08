dojo.require("dojo.widget.Breadcrumb");
dojo.provide("dojo.widget.html.Breadcrumb");

/* HtmlBreadcrumb
 ***********/
 
dojo.widget.html.Breadcrumb = function(){
	dojo.widget.html.Breadcrumb.superclass.constructor.call(this);
	this.items = [];
}
dojo.inherits(dojo.widget.html.Breadcrumb, dojo.widget.HtmlWidget);

dojo.lang.extend(dojo.widget.html.Breadcrumb, {
	widgetType: "Breadcrumb",
	isContainer: true,
        title: "",
        pane: "", // name of pane to show when the title is clicked

	// copy children widgets output directly to parent (this node), to avoid
	// errors trying to insert an <li> under a <div>
	snarfChildDomOutput: true,

	templateString: '<div></div>',
	templateCssPath: dojo.uri.dojoUri("src/widget/templates/Breadcrumb.css"),

	fillInTemplate: function (args, frag){
		//dojo.widget.HtmlBreadcrumb.superclass.fillInTemplate.apply(this, arguments);
		this.domNode.className = "dojoBreadcrumb";
                var c = document.createElement("span");
                c.innerHTML = ""
		dojo.html.disableSelection(c);
                dojo.html.addClass(c, "dojoBreadcrumbItem");
                this.domNode.appendChild(c);
         
                var c = dojo.widget.fromScript("BreadcrumbItem", { sep: " ", title: this.title, pane: this.pane });
                this.addLevel(c);

	},
	
	_register: function (item ) {
		dojo.event.connect(item, "onSelect", this, "onSelect");
		this.items.push(item);
	},

	addLevel: function (item) {
		this.domNode.appendChild(item.domNode);
		this._register(item);
                this.setSelectable();
	},
  
        setLevel: function(level) {
                while (this.items.length > level) {
                    var i = this.items.pop();
                    var b = dojo.widget.getWidgetById(i.pane);
                    if (b != null) b.hide();
                    this.domNode.removeChild(i.domNode);
                }
                this.setSelectable();
        },

        setSelectable: function() {
            var i;
            for (i = 0; i < this.items.length - 1; i++) {
                this.items[i].setSelectable();
                if (this.items[i+1].pane.length > 0) {
                    var b = dojo.widget.getWidgetById(this.items[i].pane);
                    if (b != null) b.hide();
                }
            }
            this.items[i].clearSelectable();
            var b = dojo.widget.getWidgetById(this.items[i].pane);
            if (b != null) b.show();
        },

        onSelect: function(item, e) {
            var newlevel = 0;
            for (i = 0; i < this.items.length; i++) {
                if (item == this.items[i]) {
                    this.setLevel(i + 1);
                    return;
                }
            }
        }

});

