dojo.provide("dojo.widget.DataTable");
dojo.provide("dojo.widget.html.DataTable");

dojo.require("dojo.event.*");
dojo.require("dojo.widget.*");
dojo.require("dojo.fx.html");
dojo.require("dojo.style");
dojo.require("dojo.widget.LayoutPane");
dojo.require("dojo.html");
dojo.require("dojo.io.*");

dojo.widget.html.DataTable = function() {
	dojo.widget.html.LayoutPane.call(this);
}
dojo.inherits(dojo.widget.html.DataTable, dojo.widget.html.LayoutPane);

dojo.lang.extend(dojo.widget.html.DataTable, {

	// Constructor arguments
        dataurl: "",
        edittabset: "",
        edittab: "",
	useVisibility: false,		// true-->use visibility:hidden instead of display:none
	widgetType: "DataTable",

        // Attach points
        table: null,
        title: null,
        headings: null,

        // fields
        initrows: 0,
        initcols: 0,

	templateCssPath: dojo.uri.dojoUri("src/widget/templates/HtmlDataTable.css"),
	templatePath: dojo.uri.dojoUri("src/widget/templates/HtmlDataTable.html"),

	fillInTemplate: function(args, frag) {
		dojo.widget.html.DataTable.superclass.fillInTemplate.call(this, args, frag);
		dojo.style.insertCssFile(this.templateCssPath);
		dojo.html.prependClass(this.domNode, "dojoDataTable");
                this.initrows = this.table.childNodes.length;
                this.initcols = this.headings.childNodes.length;
                this.fillInData();
        },

        onResized: function() {
            if ( !this.isVisible() ) {
			return;
		}
            this.clearData();
            this.fillInData();
        },

        clearData: function() {
            while (this.headings.childNodes.length > this.initcols) {
                this.headings.removeChild(this.headings.lastChild);
            }
            while (this.table.childNodes.length > this.initrows) {
                this.table.removeChild(this.table.lastChild);
            }
        }, 

        fillInData: function() {
                var bindArgs = {
                    url:       this.dataurl,
                    mimetype:   "text/javascript",
                    sync:       true,
                    tbldata:    null,
                    error:      function(type, errObj){
                        // handle error here
                    },
                    load:      function(type, data, evt){
                        // handle successful response here
                        this.tbldata = data;
                    }
                };

                var ro = dojo.io.bind(bindArgs);

                this.title.innerHTML = ro.tbldata.title;

                for (c = 0; c < ro.tbldata.headings.length; c++) {
                    var th = document.createElement("th");
                    dojo.html.addClass(th, "dojoDataTableColHdr");
                    th.innerHTML = ro.tbldata.headings[c];
                    this.headings.appendChild(th);
                }

                for (r = 0; r < ro.tbldata.rowdata.length; r++) {
                    var tr = document.createElement("tr");
                    var td = document.createElement("td");
                    dojo.html.addClass(td, "dojoDataTableTdSel");
                    td.align = "center";
                    td.innerHTML = '<input type="checkbox" name="DataTable.SelectionCheckbox' + r + '" value="' + ro.tbldata.rowids[r] + '" class="dojoDataTableCb" onclick="toggleTblButtonState(\'DataTable\', \'DataTableTbl\', \'tblButton\', \'ButtonDelete\', this)" onkeypress="javascript:  if (event.keyCode == 13) return false" />';
                    tr.appendChild(td);

                    td = document.createElement("td");
                    dojo.html.addClass(td, "dojoDataTableTd");
                    var a = document.createElement("a");
                    a.innerHTML = ro.tbldata.rowdata[r][0];
                    a.href = "#";
                    dojo.event.connect(a, "onclick", this, "onSelectItem");
                    td.appendChild(a);
                    tr.appendChild(td);

                    for (var i = 1; i < ro.tbldata.rowdata[r].length; i++) {
                        td = document.createElement("td");
                        td.innerHTML = ro.tbldata.rowdata[r][i];
                        dojo.html.addClass(td, "dojoDataTableTd");
                        tr.appendChild(td);
                    }
                    this.table.appendChild(tr);
                }
	},

        onSelectItem: function(e) {
            alert("item is selected: " + e + ", e.target is: " + e.currentTarget);
        },

        buttonNew: function() {
            alert("new button pressed.");
        },

        buttonDelete: function() {
            alert("delete button pressed.");
        }
});
dojo.widget.tags.addParseTreeHandler("dojo:datatable");

/**
 * Enables and Disables the Delete button of a table.
 *
 * @param formName Name of form.
 * @param tblName Name of table.
 * @param counterName Name of counter.
 * @param btn Button object.
 * @param trigger Object that triggers this event.
 */
var tblBtnCounter = new Array();
function toggleTblButtonState(formName, tblName, counterName, btn, trigger) {
    if (tblBtnCounter[counterName] == undefined) {
	tblBtnCounter[counterName] = 0;
    }
    var prevState = (tblBtnCounter[counterName] <= 0);

    if (trigger.name.indexOf('DeselectAllHref') != -1) {
	tblBtnCounter[counterName] = 0;
    } else if (trigger.name.indexOf('SelectAllHref') != -1) {
	tblBtnCounter[counterName] = countCheckboxesInTable(formName, tblName);
    } else {
	if (trigger.checked) {
	    tblBtnCounter[counterName]++;
	} else {
	    tblBtnCounter[counterName]--;
	}
    }

    var currState = (tblBtnCounter[counterName] <= 0);

    if (btn) {
	if (prevState != currState) {
            var form = document.forms[formName];
            var element = form.elements[btn];
            element.disabled = currState;
	}
    }
}

function countCheckboxesInTable(formName, tblName) {
    var frm = document.forms[formName];
    var cbCount = 0;
                                                                                
    for (var i = 0; i < frm.elements.length; i++) {
	var e = frm.elements[i];
        if ((e.type == 'checkbox') &&
	    (e.name.indexOf('.SelectionCheckbox') != -1)
        ) {
	    cbCount++;
	}
    }
    return cbCount;
}






