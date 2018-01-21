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
        if ((e.type == 'checkbox') && (e.name.indexOf('itemcheckbox') != -1 && !e.disabled)
        ) {
	    cbCount++;
	}
    }
    return cbCount;
}

/* 
 * Functions used by the enterorder and editorder pages.
 */

function lookupcust(form)
{
    var ph = escape(form.phone.value);
    if (ph == "") return;
    form.firstname.value = "Searching...";
    //var ss = document.getURL.get("enterorders.cgi?lookupcust=" + ph);
    form.firstname.value = "";
    //eval(ss + '');
}

function clearitems()
{
    for (i = 0; i < pn.length; i++) {
	pq[i] = 0;
    }
    var im = document.getElementById("custstatus");
    var im2 = document.getElementById("custstatus-orig");
    if (im != null && im2 != null) im.innerHTML = im2.innerHTML;

}

function fixedfield(n, len)
{
    var s = "" + n;
    while (s.length < len) s = " " + s;
    return s;
}

function fixedtextfield(t, len)
{
    var s = t;
    while (s.length < len) s = s + " ";
    return s;
}

function money(n)
{
    var s = "" + n;
    var i = s.indexOf(".");
    if (i == -1) s += ".00";
    else if (s.length > i + 3) s = s.substring(0, i + 3);
    if (s.match(/\.[0-9]$/)) s += "0";
    return s;
}

function edititem()
{
    var pnum = document.orderform.productnum.value;
    var pqty = document.orderform.quantity.value - 0;
    if (po[pnum]) {
	pq[pnum] = pqty;
    }
    updatelist();
}

function updatelist()
{
    var i;
    var s = "";
    var t = "";
    var subtotal = 0;
    for (i in pn) {
	if (pq[i]) {
	    s += fixedfield(i, 5) + ". " + fixedtextfield(pn[i], 40) + "     " + 
		fixedfield(pq[i], 3) + 
		" @  " + fixedfield("$" + money(pp[i]), 6) + "\n";
	    t += po[i] + ":" + pq[i] + ":";
	    subtotal += pq[i] * pp[i];
	}
    }
    var total = subtotal;
    document.orderform.itemdisplay.value = s;
    document.orderform.items.value = t;
    document.orderform.total.value = "$" + money(total);
    setTimeout(resetrefocus, 5);
}

function resetrefocus()
{
    document.orderform.productnum.value = "";
    document.orderform.quantity.value = "";
    document.orderform.productnum.focus();
}

function checkData(form)
{
    if (form.seller.options[0].selected) {
	alert("You must select a seller for this order.");
	return false;
    }
    if (!form.orderdate.value.match(/^[0-9][0-9][0-9][0-9]-[0-9]+-[0-9]+$/)) {
        alert("Invalid order date.  Use YYYY-MM-DD format.");
        return false;
    }
    if (form.srequest.value.length > 255) {
	alert("The special request field must be less than 255 characters.");
	return false;
    }
    if (form.email.value != "" && !form.email.value.match(/^[0-9a-zA-Z._\-]+@[0-9a-zA-Z._\-]+\.[0-9a-zA-Z_\-]+/)) {
        alert("Invalid email address. The address must have an @ and may not have spaces or special characters.");
        return false;
    }
    return true;
}

function hideinfomsg()
{
    var im = document.getElementById("infoMessage");
    if (im != null) im.style.display = "none";
}

// Run wait animation
var wait_frame = 0;
var waitFramesLoaded = 0;
var waitFrames;

function waitAnimate()
{
    var waitImage = (!document.layers) ? document.images["waiting"] : document.layers["waitScreen"].document.images["waiting"]
    wait_frame = (++wait_frame) % 9
    if(waitImage)
      waitImage.src=waitFrames[wait_frame].src
    setTimeout("waitAnimate()", 250)
}


function runWaitScreen()
{
    if (!waitFramesLoaded)
    {
        waitFramesLoaded = 1;
        waitFrames = new Array(9);
        for (i=0; i<9; i++) 
        {  
            waitFrames[i] = new Image; 
            waitFrames[i].src = "images/flwrpotgrow"+(i+1)+".gif"; 
        }
    }
    var obj2 = document.getElementById("waitScreen");
    obj2.style.visibility="visible";
    obj2.style.zindex = 0;
    obj2.style.width = "100%";
    obj2.style.height = "100%";
    window.scrollTo(0,0);
    waitAnimate();
}