Ajax.Responders.register({
  onException: function(transport, exception) {
	show_error_dialog(t('js_error_during_xhr', null, "Javascript-fout tijdens XHR") + ": " + exception);
  }
});

function show_ajax_error_dialog (transport) {
	set_loading(false);
	show_error_dialog("<div style='height: 300px; overflow: auto;'>" + transport.responseText + "</div>");
}

var __retain_loader;
function set_loading(state) {
	if (state) {
	  if (YAHOO.wait) {
	    YAHOO.wait.hide();
    }
		YAHOO.wait = new YAHOO.widget.Panel("wait", {
			width: "240px", 
			fixedcenter: true, 
			close: false, 
			draggable: false, 
			zindex: 4,
			modal: true,
			visible: false
			} 
		);

	    YAHOO.wait.setHeader(t('loading', null, 'Bezig met laden...'));
	    YAHOO.wait.setBody('<img src="/crud/images/loading.gif" />');
	    YAHOO.wait.render(document.body);
	    YAHOO.wait.show();
	} else {
		YAHOO.wait.hide();
	}
}

function crud_go_page (target, target_page) {
	set_loading(true);

	if ($('page')) {
	  $('page').value = target_page;
	}
	
	if ($('query')) {
	  target += "&query=" + encodeURIComponent($('query').value);
	}

	new Ajax.Request(target, {
		method: 'get',
		onComplete: function(transport) {
			$('list').innerHTML = transport.responseText;
			set_loading(false);
		},
		onFailure: function(transport) {
			show_ajax_error_dialog(transport);
  	}
	});
	return false;
}

function crud_go_sort (target, target_page, sort_column, sort_dir) {
  if ($('sort')) {
    $('sort').value = sort_column;
  }
  if ($('dir')) {
    $('dir').value = sort_dir;
  }
	crud_go_page(target, target_page)
}

function crud_reload_list (use_loader) {
	if (use_loader) {
		set_loading(true);
	}
	
	target = $('list').select("table")[0].getAttribute("for");
	
	if ($('list_search')) {
		target += "&" + Form.serialize('list_search');
	}
	
	new Ajax.Request(target, {
		method: 'get',
		onComplete: function(transport) {
			$('list').innerHTML = transport.responseText;
			if (use_loader) {
				set_loading(false);
			}
		},
		onFailure: function(transport) {
			show_ajax_error_dialog(transport);
	  	}
	});
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
function crud_show (e, url, id) {	
	if (!e) var e = window.event;
	if (e && (e.ctrlKey || e.altKey || e.metaKey)) return true;
	if (!$('show_options')) return;

	if ($("show_options").hasAttribute("show_in_dialog")) {
	  if ($("show_options").getAttribute("show_in_dialog") == "false") {
	    return true;
	  }
	}

	if (id) {
		window.location.hash = id;
	}
	
	//
	// Als deze show-actie wordt aangeroepen terwijl we al
	// in een show eerst huidig dialoog sluiten
	//
	if (YAHOO.show) {
		try {
			YAHOO.show.cancel();
		} catch (e) { }
	}
	
	set_loading(true);

	new Ajax.Request(url, {
		method: 'get',
		onSuccess: function(transport) {
			var dialog_buttons = [];
			
			var link_container = transport.responseText.replace(/[\r\n]/g,"").replace(/.*?action_links.*?>(.*?)<\/div>.*/g,"$1");
			link_container.split(/<\/a>/).each(function(item) {
				if (/list_link/.test(item) ||
					/edit_link/.test(item) ||
					/static_delete_link/.test(item) ||
					/delete_link/.test(item) ||
					/delete_verify/.test(item)) {
					return;
				}
				var button_label = item.replace(/\<.*?\>/g,"").replace(/^\s+|\s+$/, '');
				var button_target = item.replace(/.*?<.*?href=['"](.*?)['"].*/,"$1").replace(/^\s+|\s+$/, '');
				var button_onclick = /onclick/.test(item.toLowerCase()) ? item.replace(/.*?<.*?onclick=['"](.*?)['"].*/,"$1") : "";
				if (button_label != "" && button_target != "") {
					var button_data = {
						target: button_target,
						onclick: button_onclick
					};
					dialog_buttons[dialog_buttons.length] = {
						text: button_label,
						handler: {
							fn: function() {
								if (this.onclick!="") {
									try {
										eval("var fun = function() { " + this.onclick.replace(/&quot;/g,'"') +"}" );
										if (fun() === false) {
											return;
										}
									} catch(e) {
										alert(e);
									}
									YAHOO.show.cancel();
								} else {
									YAHOO.show.cancel();
									set_loading(true);
									window.location = this.target;
								}
							},
							scope: button_data
						}
					};
				}
			});
			
			//
			// Als we deze show-actie als sub van een create- of edit-actie
			// laten zien het muteren uitschakelen
			//
			if (!YAHOO.edit) {
				if (/id=[\'\"]edit_link[\'\"]/.test(transport.responseText)) {
					dialog_buttons[dialog_buttons.length] = { text: t('edit_action', null, "Bewerken"), handler: crud_show_edit };
				}
				if (/id=[\'\"]delete_link[\'\"]/.test(transport.responseText)) {
					dialog_buttons[dialog_buttons.length] = { text: t('destroy_action', null, "Verwijderen"), handler: crud_show_delete };
				}
			}
			dialog_buttons[dialog_buttons.length] = { text: t('close_action', null, "Sluiten"), handler: crud_show_cancel, isDefault: true };
			
			YAHOO.show = new YAHOO.widget.Dialog("show", {
				width: $("show_options").getAttribute("dialog_width")+"px",
				fixedcenter: true, 
				zindex: 4,
				modal: true,
				visible : false,
				constraintoviewport : true,
				buttons : dialog_buttons,
				close: false
			});
			
			register_dialog_handler(
				YAHOO.show,
				crud_show_cancel,
				crud_show_cancel
			);
			
			YAHOO.show.setHeader(transport.responseText.split(/[\r\n]/)[0].replace(/.*?\<h2\>(.*)?\<\/h2\>.*/,"$1"));
			YAHOO.show.setBody(transport.responseText.replace(/\<h2\>.*?\<\/h2\>/,""));
			YAHOO.show.render(document.body);

			__retain_loader = false;
			if ($("show_options").hasAttribute("post_render")) {
				eval($("show_options").getAttribute("post_render"))
			}

			if ($("show_options").hasAttribute("evaljs")) {
				transport.responseText.evalScripts(); // Ajax options evalJS werkt niet bij een Ajax.Request
			}
			YAHOO.show.show();
			
			
			
			if (!__retain_loader) {
				set_loading(false);
			} else {
				set_loading(false);
				set_loading(true);
			}
		},
		onFailure: function(transport) {
			show_ajax_error_dialog(transport);
	  	}
	});
	return false;
}

var crud_show_cancel = function() {
	YAHOO.show.destroy();
	YAHOO.show = null;
};
var crud_show_edit = function() {
	set_loading(true);
	if ($("edit_options").hasAttribute("show_in_dialog")) {
	  if ($("edit_options").getAttribute("show_in_dialog") == "false") {
	    window.location = $('edit_link').href;
	    return true;
	  }
	}

	new Ajax.Request($('edit_link').href, {
		method: 'get',
		onSuccess: function(transport) {
			YAHOO.edit = new YAHOO.widget.Dialog("edit", {
				width: $("edit_options").getAttribute("dialog_width")+"px",
				fixedcenter: true, 
				zindex: 4,
				modal: true,
				visible : false,
				constraintoviewport : true,
				buttons : [
					{ text: t('cancel_action', null, "Annuleren"), handler: crud_edit_cancel },
					{ text: t('save_action', null, "Opslaan"), handler: crud_edit_save, isDefault: true }
				],
				close: false
			});
			
			register_dialog_handler(
				YAHOO.edit,
				crud_edit_cancel,
				crud_edit_save
			);

			YAHOO.edit.setHeader(transport.responseText.split(/[\r\n]/)[0].replace(/.*?\<h2\>(.*)?\<\/h2\>.*/,"$1"));
			YAHOO.edit.setBody(transport.responseText.replace(/\<h2\>.*?\<\/h2\>/,""));
			YAHOO.edit.render(document.body);
			__retain_loader = false;
			if ($("edit_options").hasAttribute("post_render")) {
				eval($("edit_options").getAttribute("post_render"))
			}
			if ($("edit_options").hasAttribute("evaljs")) {
				transport.responseText.evalScripts(); // Ajax options evalJS werkt niet bij een Ajax.Request
			}
			YAHOO.edit.show();
			convert_ckeditors();
			convert_all_ajax_pulldowns();
      
			if (!__retain_loader) {
				set_loading(false);
			} else {
				set_loading(false);
				set_loading(true);
			}
		},
		onFailure: function(transport) {
			show_ajax_error_dialog(transport);
	  	}
	});
	YAHOO.show.destroy();
	YAHOO.show = null;
};
var crud_show_delete = function() {
	var target = $('delete_link').href;
	var confirm_text = $('delete_verify').innerHTML;
	var authenticity_token = $('authenticity_token').innerHTML;
	var show_box = this;
	
	// Instantiate the Dialog
	YAHOO.confirm = new YAHOO.widget.SimpleDialog("confirm", {
		width: "300px",
		fixedcenter: true,
		visible: false,
		draggable: false,
		modal: true,
		close: false,
		text: confirm_text,
		icon: YAHOO.widget.SimpleDialog.ICON_HELP,
		constraintoviewport: true,
		buttons: [
			{
				text: t('destroy_action', null, "Verwijderen"),
				isDefault: true,
				handler: function() {
					YAHOO.confirm.destroy();
					YAHOO.confirm = null;
					show_box.destroy();
					show_box = null;
					set_loading(true);
					new Ajax.Request(target, {
						parameters: { authenticity_token: authenticity_token },
						method: 'delete',
						onSuccess: function(transport) {
							set_loading(false);
							crud_reload_list(true);
						},
						onFailure: function(transport) {
							show_ajax_error_dialog(transport);
					  	}
					});
				}
			},{
				text: t('cancel_action', null, "Annuleren"),
				handler: function() {
					YAHOO.confirm.destroy();
					YAHOO.confirm = null;
				}
			}
		]
	});
	register_dialog_handler(
		YAHOO.confirm,
		function() {
			YAHOO.confirm.destroy();
			YAHOO.confirm = null;
		},
		function() {
			YAHOO.confirm.destroy();
			YAHOO.confirm = null;
		}
	);
	
	YAHOO.confirm.render(document.body);

	YAHOO.confirm.show();
};
var crud_edit_cancel = function() {
	target = $('show_link').href;
	YAHOO.edit.destroy();
	YAHOO.edit = null;
	crud_show(null, target);
}
var __continue_save;
var crud_edit_save = function() {
	__continue_save = true;
	if ($("edit_options").hasAttribute("pre_submit")) {
		try{
			eval( "var fun = function() { " + $("edit_options").getAttribute("pre_submit") +"}" );
			if( fun() === false ) {
				return;
			}
		} catch( e ) {
			alert( e );
		}
	}
	if (!__continue_save) {
		return false;
	}
	var form = $('crud_edit');
	update_ckeditors();
	var parameters = Form.serialize(form);
	var action = form.action;
	var method = "post";//form.method;
	target = $('show_link').href;
	YAHOO.edit.hide();
	set_loading(true);
	new Ajax.Request(action, {
		asynchronous: true,
		evalScripts: false,
		method: method,
		parameters: parameters,
		onSuccess: function(transport) {
			if (transport.responseText == "OK") {
				YAHOO.edit.destroy();
				YAHOO.edit = null;
				crud_reload_list(false);
				set_loading(false);
				// crud_show(target);
			} else if( transport.getHeader("Content-Type").indexOf('javascript') >= 0  ) {
				transport.responseText.evalScripts(); // Ajax options evalJS werkt niet bij een Ajax.Request
			} else {
				if ($('errorExplanation')) {
					$('errorExplanation').parentNode.removeChild($('errorExplanation'));
				}
				
				var target = $$('#edit .bd')[0];
				target.innerHTML = transport.responseText.replace(/\<h2\>.*?\<\/h2\>/,"");
				var errors = false;
				
				if ($("edit_options").hasAttribute("error_display") && $("edit_options").getAttribute("error_display") == "popup") {
					errors = "<div id='errorExplanation'>" + $('errorExplanation').innerHTML + "</div>";
					$('errorExplanation').parentNode.removeChild($('errorExplanation'));
				}
				
				__retain_loader = false;
				if ($("edit_options").hasAttribute("post_render")) {
					eval($("edit_options").getAttribute("post_render"))
				}
				if ($("edit_options").hasAttribute("evaljs")) {
					transport.responseText.evalScripts(); // Ajax options evalJS werkt niet bij een Ajax.Request
				}

				YAHOO.edit.show();
  			convert_ckeditors();
  			convert_all_ajax_pulldowns();
				if (!__retain_loader) {
					set_loading(false);
				} else {
					set_loading(false);
					set_loading(true);
				}

				if (errors) {
					show_error_dialog(errors);
				}
			}
		},
		onFailure: function(transport) {
			show_ajax_error_dialog(transport);
	  	}
	});
};

function crud_add (e, url) {
	if (!e) var e = window.event;
	if(e.ctrlKey || e.altKey || e.metaKey) return true;
	if ($("create_options").hasAttribute("show_in_dialog") && $("create_options").getAttribute("show_in_dialog") == "false") {
    	return true;
	}

	set_loading(true);

	new Ajax.Request(url, {
		method: 'get',
		onSuccess: function(transport) {
			
			if (/<form/i.test(transport.responseText)) {
			  var buttons = [
  				{ text: t('cancel_action', null, "Annuleren"), handler: crud_add_cancel },
  				{ text: t('save_action', null, "Opslaan"), handler: crud_add_save, isDefault: true }
  			];
			} else {
  		  var buttons = [
  				{ text: t('cancel_action', null, "Annuleren"), handler: crud_add_cancel, isDefault: true }
  			];
			  
			}
		  
			YAHOO.add = new YAHOO.widget.Dialog("add", {
				width: $("create_options").getAttribute("dialog_width")+"px",
				fixedcenter: true, 
				zindex: 4,
				modal: true,
				visible : false,
				constraintoviewport : true,
				buttons : buttons,
				close: false
			});

			register_dialog_handler(
				YAHOO.add,
				crud_add_cancel,
				crud_add_save
			);

			YAHOO.add.setHeader(transport.responseText.split(/[\r\n]/)[0].replace(/.*?\<h2\>(.*)?\<\/h2\>.*/,"$1"));
			YAHOO.add.setBody(transport.responseText.replace(/\<h2\>.*?\<\/h2\>/,""));
			YAHOO.add.render(document.body);

			__retain_loader = false;
			if ($("create_options").hasAttribute("post_render")) {
				eval($("create_options").getAttribute("post_render"))
			}
			if ($("create_options").hasAttribute("evaljs")) {
				transport.responseText.evalScripts(); // Ajax options evalJS werkt niet bij een Ajax.Request
			}
			YAHOO.add.show();
			convert_ckeditors();
			convert_all_ajax_pulldowns();
            
			if (!__retain_loader) {
				set_loading(false);
			} else {
				set_loading(false);
				set_loading(true);
			}
		},
		onFailure: function(transport) {
			show_ajax_error_dialog(transport);
	  	}
	});
	return false;
}

var crud_add_save = function() {
	__continue_save = true;
	if ($("create_options").hasAttribute("pre_submit")) {
		eval($("create_options").getAttribute("pre_submit"))
	}
	if (!__continue_save) {
		return false;
	}
	var form = $('crud_add');
	update_ckeditors();
	var parameters = Form.serialize(form);
	var action = form.action;
	var method = form.method;
	YAHOO.add.hide();
	set_loading(true);
	new Ajax.Request(action, {
		asynchronous: true,
		evalScripts: false,
		method: method,
		parameters: parameters,
		onSuccess: function(transport) {
			if (transport.responseText == "OK") {
				set_loading(false);
				crud_add_success();
			} else if( transport.getHeader("Content-Type").indexOf('javascript') >= 0  ) {
				transport.responseText.evalScripts(); // Ajax options evalJS werkt niet bij een Ajax.Request
			} else {
				if ($('errorExplanation')) {
					$('errorExplanation').parentNode.removeChild($('errorExplanation'));
				}
				var target = $$('#add .bd')[0];
				target.innerHTML = transport.responseText.replace(/\<h2\>.*?\<\/h2\>/,"");

				var errors = false;
				
				if ($("create_options").hasAttribute("error_display") && $("create_options").getAttribute("error_display") == "popup") {
					errors = "<div id='errorExplanation'>" + $('errorExplanation').innerHTML + "</div>";
					$('errorExplanation').parentNode.removeChild($('errorExplanation'));
				}
				
				__retain_loader = false;
				if ($("create_options").hasAttribute("post_render")) {
					eval($("create_options").getAttribute("post_render"))
				}
				if ($("create_options").hasAttribute("evaljs")) {
					transport.responseText.evalScripts(); // Ajax options evalJS werkt niet bij een Ajax.Request
				}

				YAHOO.add.show();
  			convert_ckeditors();
  			convert_all_ajax_pulldowns();
				if (!__retain_loader) {
					set_loading(false);
				} else {
					set_loading(false);
					set_loading(true);
				}

				if (errors) {
					show_error_dialog(errors);
				}
			}
		},
		onFailure: function(transport) {
			show_ajax_error_dialog(transport);
	  	}
	});
}
var crud_add_cancel = function() {
	YAHOO.add.destroy();
	YAHOO.add = null;
};
var crud_add_success = function() {
	YAHOO.add.destroy();
	YAHOO.add = null;
	
	//
	// Reloads current page
	//
	crud_reload_list(true);
}

function show_error_dialog (errors) {
	YAHOO.errordialog = new YAHOO.widget.Dialog("errordialog", {
		width: "450px",
		fixedcenter: true, 
		zindex: 4,
		modal: true,
		visible : false,
		constraintoviewport : true,
		buttons : [
			{ text: "Ok", handler: crud_error_cancel, isDefault: true }
		],
		close: false
	});
    YAHOO.errordialog.setHeader(t('error_while_saving', null, 'Fout bij opslaan...'));
    YAHOO.errordialog.setBody(errors);
    YAHOO.errordialog.render(document.body);
	if ($('errorExplanation')) {
		$('errorExplanation').style.marginBottom = "0";
	}
    YAHOO.errordialog.show();
}

var crud_error_cancel = function() {
	YAHOO.errordialog.destroy();
	YAHOO.errordialog = null;
}

function show_help (ref) {
	YAHOO.helpdialog = new YAHOO.widget.Dialog("helpdialog", {
		width: "450px",
		fixedcenter: true, 
		zindex: 4,
		modal: true,
		visible : false,
		constraintoviewport : true,
		buttons : [
			{ text: "Ok", handler: crud_help_cancel, isDefault: true }
		],
		close: false
	});
    YAHOO.helpdialog.setHeader('?');
    YAHOO.helpdialog.setBody(ref.parentNode.getElementsByTagName("span")[0].innerHTML);
    YAHOO.helpdialog.render(document.body);
    YAHOO.helpdialog.show();
}

var crud_help_cancel = function() {
	YAHOO.helpdialog.destroy();
	YAHOO.helpdialog = null;
}

//
// Calendar
//
var calendar;
var calendar_dialog;
var calendar_target;
function show_calendar (target) {
	calendar_target = target;
	
	if (!calendar_dialog) {
		// Event.observe(document, "click", function(e) {
		//         var el = Event.getTarget(e);
		//         var dialogEl = calendar_dialog.element;
		//         if (el != dialogEl && !Dom.isAncestor(dialogEl, el) && el != showBtn && !Dom.isAncestor(showBtn, el)) {
		//             calendar_dialog.hide();
		//         }
		//     });

    function resetHandler() {
        // Reset the current calendar page to the select date, or 
        // to today if nothing is selected.
        var selDates = calendar.getSelectedDates();
        var resetDate;

        if (selDates.length > 0) {
            resetDate = selDates[0];
        } else {
            resetDate = calendar.today;
        }

        calendar.cfg.setProperty("pagedate", resetDate);
        calendar.render();
    }

    function closeHandler() {
        calendar_dialog.hide();
    }

    calendar_dialog = new YAHOO.widget.Dialog("container", {
        visible: false,
				draggable: false,
				fixedcenter: true,
				modal: true,
        context:["show", "tl", "bl"],
        buttons:[
			{text: t('today', null, "Vandaag"), handler: resetHandler}, 
			{text: t('close_action', null, "Sluiten"), handler: closeHandler, isDefault:true}
		],
        close: true
    });
    calendar_dialog.setHeader(t('select_date', null, 'Kies een datum'));
    calendar_dialog.setBody('<div id="cal"></div>');
    calendar_dialog.render(document.body);

    calendar_dialog.showEvent.subscribe(function() {
        if (YAHOO.env.ua.ie) {
            // Since we're hiding the table using yui-overlay-hidden, we 
            // want to let the dialog know that the content size has changed, when
            // shown
            calendar_dialog.fireEvent("changeContent");
        }
    });
	}
	
	if (!calendar) {
		calendar = new YAHOO.widget.Calendar("cal", {
			iframe:false,          // Turn iframe off, since container has iframe support.
			hide_blank_weeks:true  // Enable, to demonstrate how we handle changing height, using changeContent
		});
		
		
		calendar.cfg.setProperty("WEEKDAYS_SHORT", t('date.abbr_day_names', null, ["Zo", "Ma", "Di", "Wo", "Do", "Vr", "Za"])); 
		calendar.cfg.setProperty("MONTHS_LONG", ["Januari", "Februari", "Maart", "April", "Mei", "Juni", "Juli", "Augustus", "September", "Oktober", "November", "December"]);
		if (t('date.month_names')) {
			months = t('date.month_names');
			calendar.cfg.setProperty("MONTHS_LONG", [months[1], months[2], months[3], months[4], months[5], months[6], months[7], months[8], months[9], months[10], months[11], months[12]]);
		}

		calendar.render();

		calendar.selectEvent.subscribe(function() {
			if (calendar.getSelectedDates().length > 0) {

				var selDate = calendar.getSelectedDates()[0];

				// Pretty Date Output, using Calendar's Locale values: Friday, 8 February 2008
				var dStr = (selDate.getDate() <= 9)?"0"+(selDate.getDate()):selDate.getDate();
				var mStr = (selDate.getMonth()+1 <= 9)?"0"+(selDate.getMonth()+1):selDate.getMonth()+1;
				var yStr = selDate.getFullYear();

				$(calendar_target+"_3i").value = (dStr+"").replace(/^0/,"");
				$(calendar_target+"_2i").value = (mStr+"").replace(/^0/,"");
				$(calendar_target+"_1i").value = yStr;
			} else {
				calendar_target.value = "";
			}
			calendar_dialog.hide();
		});

		calendar.renderEvent.subscribe(function() {
			// Tell Dialog it's contents have changed, which allows 
			// container to redraw the underlay (for IE6/Safari2)
			calendar_dialog.fireEvent("changeContent");
		});
	}

	var seldate = calendar.getSelectedDates();

	if (seldate.length > 0) {
		// Set the pagedate to show the selected date if it exists
		calendar.cfg.setProperty("pagedate", seldate[0]);
		calendar.render();
	}

	calendar_dialog.show();
}

//
// Iframe submit
//
var crud_submit_dialog;
function crud_do_iframe_submit () {
	__continue_save = false;
	if ($('add') || $('edit')) {
		if (!$("crud_upload_frame")) {
			var iframe = document.createElement("div");
			iframe.innerHTML = '<iframe name="crud_upload_frame" id="crud_upload_frame" style="display: none;" onload="submit_complete()" />';
			document.body.appendChild(iframe);
		}
		if ($('add')) {
			crud_submit_dialog = YAHOO.add;
		}
		if ($('edit')) {
			crud_submit_dialog = YAHOO.edit;
		}

		crud_submit_dialog.hide();
		update_ckeditors();
		set_loading(true);
		if ($('crud_add')) {
			$('crud_add').target = "crud_upload_frame";
			$('crud_add').action = $('crud_add').action + "?xhr=1"
			$('crud_add').submit();
		} else if ($('crud_edit')) {
			$('crud_edit').target = "crud_upload_frame";
			$('crud_edit').action = $('crud_edit').action + "?xhr=1"
			$('crud_edit').submit();
		}
	}
}
function submit_complete () {
	if (crud_submit_dialog) {
		data = window.crud_upload_frame.document.body.innerHTML;
		if (/errorExplanation/.test(data+"")) {
			set_loading(false);
			var errors = "";
			if ($('add')) {
				$("add").select(".bd")[0].innerHTML = data.replace(/[\r\n]/,"").replace(/\<h2\>.*?\<\/h2\>/i,"")
				
				if ($("create_options").hasAttribute("error_display") && $("create_options").getAttribute("error_display") == "popup") {
					errors = "<div id='errorExplanation'>" + $('errorExplanation').innerHTML + "</div>";
					$('errorExplanation').parentNode.removeChild($('errorExplanation'));
				}

				if ($("create_options").hasAttribute("post_render")) {
					eval($("create_options").getAttribute("post_render"))
				}
			} else if ($('edit')) {
				$("edit").select(".bd")[0].innerHTML = data.replace(/[\r\n]/,"").replace(/\<h2\>.*?\<\/h2\>/i,"")

				if ($("edit_options").hasAttribute("error_display") && $("edit_options").getAttribute("error_display") == "popup") {
					errors = "<div id='errorExplanation'>" + $('errorExplanation').innerHTML + "</div>";
					$('errorExplanation').parentNode.removeChild($('errorExplanation'));
				}
				if ($("edit_options").hasAttribute("post_render")) {
					eval($("edit_options").getAttribute("post_render"))
				}
			}
			crud_submit_dialog.show();
			convert_ckeditors();
			convert_all_ajax_pulldowns();
			
			if (errors!="") {
				show_error_dialog(errors);
			}
		} else {
		  if (YAHOO.edit) {
		  YAHOO.edit = null;
		}
		if (YAHOO.add) {
		  YAHOO.add = null;
		}
			crud_reload_list(false);
			crud_submit_dialog.destroy();
			set_loading(false);
		}
	}
}


function crud_update_currency (ref) {
  ref.value = isNaN(parseFloat(ref.value.replace(/\,/,"."))) ? "" : parseFloat(ref.value.replace(/\,/,".")).toFixed(2);
}

function convert_ckeditors () {
  if (typeof(CKEDITOR) == "undefined") { return; }
  $$("textarea").each(function(textarea) {
		if (!(/text_only/.test(textarea.className))) {
	    if (CKEDITOR.instances[textarea.id]) {
				try {
					CKEDITOR.remove(CKEDITOR.instances[textarea.id]);
					// CKEDITOR.instances[textarea.id].destroy();
				} catch (e) { }
	    }
	    CKEDITOR.config.contentsCss = '/crud/stylesheets/ckeditor.css' 
	    CKEDITOR.config.linkShowAdvancedTab = false;
	    CKEDITOR.config.linkShowTargetTab = false;
	    CKEDITOR.replace(textarea, {
	      toolbar: [
	        ['Bold','Italic','Underline','Strike','-','NumberedList','BulletedList','-','Outdent','Indent','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
	        ['Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo','-','SelectAll','RemoveFormat'],
	        '/',
	        ['Format'],
	        ['TextColor','BGColor'],
	        ['Link','Unlink'],
	        ['Image','Table','HorizontalRule','SpecialChar'],
	      ]
	    });
		}
  });
}
function update_ckeditors () {
  if (typeof(CKEDITOR) == "undefined") { return; }
  $$("textarea").each(function(textarea) {
		if (!(/text_only/.test(textarea.className))) {
	    if (CKEDITOR.instances[textarea.id]) {
				CKEDITOR.instances[textarea.id].updateElement();
	    }
		}
  });
}
Event.observe(window, 'load', function() {
  convert_ckeditors();
  // note: onclick werkt niet!
  // $$(".contentbox a").each(function(a) {
  //   if (a.className != "invisible_link" && a.className != "dummy") {
  //     new YAHOO.widget.Button(a); 
  //   }
  // });
  $$(".contentbox input[type='submit']").each(function(input) { new YAHOO.widget.Button(input); });
  $$(".contentbox input[type='button']").each(function(input) { new YAHOO.widget.Button(input); });
});

//
// ajax pulldown
//
function convert_all_ajax_pulldowns() {
  $$(".in_ajax_select").each(function(item) {
    if (item.converted != "true") {
      item.converted = "true";
      item.observe('mouseover', function() {
        if (!(/active/.test(this.className))) {
          this.className = 'in_ajax_select in_ajax_select_hover';
        }
      })
      item.observe('mouseout', function() {
        if (!(/active/.test(this.className))) {
          this.className = 'in_ajax_select';
        }
      })
      item.observe('keydown', function(e) {
				if (!e) var e = window.event;
				if (e && (e.ctrlKey || e.altKey || e.metaKey)) return true;
				if (e.keyCode != 9 && e.keyCode != 13 && e.keyCode != 27 && e.keyCode != 16) {
					click_ajax_select(this);
				}
			});

      item.observe('click', function(event) {
				click_ajax_select(this);
        event.stop();
      })
    }
  });
}
function click_ajax_select (ref) {
  //
  // Eerst de andere sluiten...
  //
  var me = ref;
  $$(".in_ajax_select_active").each(function(item) { if (item!=me) { item.className = 'in_ajax_select'; } });
  $$(".ajax_select_popup").each(function(item) { 
		if (item!=me) { 
			if ($(item.id.replace("_container","")+"_id").hasAttribute("js_filter_params")) {
				item.parentNode.removeChild(item);
			}
			
			item.style.display = "none";
		}
	});
  
  var target_id = ref.id + "_container";
  if (/active/.test(ref.className)) {
    var target=$(target_id);
    if (target) {
			if ($(target.id.replace("_container","")+"_id").hasAttribute("js_filter_params")) {
				target.parentNode.removeChild(target);
			}
	
      target.style.display = "none";
    }
    ref.className = 'in_ajax_select';
  } else {
    if (!$(target_id)) {
      var div = $(ref.parentNode.appendChild(document.createElement("div")));
      div.id = target_id;
      div.className = 'ajax_select_popup';
      div.absolutize();
      div.style.top = (div.positionedOffset()[1] - 3) + "px";
      div.style.width = (ref.offsetWidth - 2)+ "px";
      div.style.zIndex = 105;
      div.observe('click', function(event) {
        event.stop();
      });

      div.style.height = "";

      var searchbox = $(div.appendChild(document.createElement("div")));
      searchbox.className = 'search';

      var searchinput = $(searchbox.appendChild(document.createElement("input")));
      searchinput.type = 'text';
      searchinput.id = div.id + "_searchinput";
      searchinput.style.width = (ref.offsetWidth - 28)+ "px";
      searchinput.value = " ";
      searchinput.focus();
    
      searchinput.observe('keydown', function(e) {
				if (!e) var e = window.event;
				if (e && (e.ctrlKey || e.altKey || e.metaKey)) return true;
				if (e.keyCode == 38 /* up */ || e.keyCode == 40 /* down */ || e.keyCode == 13) {
	        var resultcontainer = $(this.id.replace("_searchinput","_searchresults"));
					if (resultcontainer) {
						var current_selected_index = -1;
						var results = resultcontainer.select(".searchresult");
						results.each(function(item, ix) {
							if (/searchresult_hover/.test(item.className)) {
								if (e.keyCode == 13) {
									item.fire("item:click");
								}
								current_selected_index = ix;
							}
						});
					
						if (current_selected_index==-1) {
							if (e.keyCode == 38) {
								current_selected_index = results.length - 1;
							} else {
								current_selected_index = 0;
							}
						} else {
							if (e.keyCode == 38) {
								current_selected_index = current_selected_index > 0 ? current_selected_index - 1 : results.length - 1;
							} else {
								current_selected_index = current_selected_index < results.length - 1 ? current_selected_index + 1 : 0;
							}
						}

						results.each(function(item, ix) {
							item.className = ix == current_selected_index ? 'searchresult searchresult_hover' : 'searchresult';
						});
					}
				}
				
				if (e.keyCode == 9) {
					$$(".in_ajax_select_active").each(function(item) { item.className = 'in_ajax_select'; });
          $$(".ajax_select_popup").each(function(item) { item.style.display = "none"; });
				}
				if (e.keyCode == 13) {
					__prevent_dialog_handler_action = true;
					Event.stop(e);
				}
			});

			//
			// Prevent submit on enter
			//
      searchinput.observe('keyup', function(e) {
				if (!e) var e = window.event;
				if (e && (e.ctrlKey || e.altKey || e.metaKey)) return true;
				if (e.keyCode == 27) {
					$(this.id.replace("_container_searchinput","")).focus();
					$$(".in_ajax_select_active").each(function(item) { item.className = 'in_ajax_select'; });
          $$(".ajax_select_popup").each(function(item) { item.style.display = "none"; });
					Event.stop(e);
				}
				if (e.keyCode == 13) {
					__prevent_dialog_handler_action = true;
					Event.stop(e);
				}
			});

      var searchimg = $(searchbox.appendChild(document.createElement("img")));
      searchimg.src = '/crud/images/spinner.gif';
      searchimg.style.display = "none";
      searchimg.id = div.id + "_searchimg";
    
      var searchresults = $(div.appendChild(document.createElement("div")));
      searchresults.className = 'searchresults';
      searchresults.style.overflow = "auto";
      searchresults.id = div.id + "_searchresults";

      new Form.Element.Observer(
        div.id + "_searchinput",
        1,
        function(el, value){
          if ($(div.id + "_searchimg").style.display == "none") {
            $(div.id + "_searchinput").style.width = ($(div.id + "_searchinput").offsetWidth - 26) + "px";
            $(div.id + "_searchimg").style.display = "inline";
          }
        
          var form = el;
          do {
            form = form.parentNode;
          } while (form.tagName.toLowerCase() != "form" && form.parentNode);

					var parameters = {
            type: 'live_record_search',
            record: div.id.replace("_container",""),
            q: value,
            a: $('crud_add') ? 'new' : 'edit'
          };
          
					if ($(div.id.replace("_container","")+"_id").hasAttribute("js_filter_params")) {
						$A($(div.id.replace("_container","")+"_id").getAttribute("js_filter_params").split(",")).each(function(js_filter_param) {
							if ($(js_filter_param)) {
								parameters[js_filter_param] = $(js_filter_param).value;
							}
						});
					}
					
          new Ajax.Request(form.action, {
            method: 'get',
						parameters: parameters,
            onComplete: function(transport) {
              var results = $(el.id.replace("_searchinput","_searchresults"));
							if (!$(div.id + "_searchimg")) {
								return;
							}
              if ($(div.id + "_searchimg").style.display != "none") {
                $(div.id + "_searchimg").style.display = "none";
                $(div.id + "_searchinput").style.width = ($(div.id + "_searchinput").parentNode.parentNode.offsetWidth - 28) + "px";
              }
              results.innerHTML = "";
              if (transport.responseText!='') {
                if (value == "") {
                  var data = [];
                  data[0] = ["&nbsp;","",""];
                  var responsedata = transport.responseText.evalJSON();
                  for (var c=0; c<4; c++) {
                    if (responsedata.length > c) {
                      data[c+1] = responsedata[c];
                    }
                  }
                } else {
                  var data = transport.responseText.evalJSON();
                }

                results.className = "searchresults searchresults_" + data.length;
                div.className = "ajax_select_popup ajax_select_popup_" + data.length;

                data.each(function(itemdata) {
                  var item = $(results.appendChild(document.createElement("div")));
                  item.innerHTML = itemdata[0];
                  item.className = 'searchresult';
                  item.observe('mouseover', function() {
										$(this.parentNode.select(".searchresult")).each(function(item, ix) {
											item.className = 'searchresult';
										});
										this.className = 'searchresult searchresult_hover'; 
									});
                  item.observe('mouseout', function() { this.className = 'searchresult'; });
                  item.observe('click', function(event) {
										this.fire("item:click");
                  });
									// alleen custom events kunnen worden gefired...
                  item.observe('item:click', function(event) {
										//
										// Fire onchange event
										//
										var id_field = $(div.id.replace("_container","")+"_id");
                    id_field.value = itemdata[1];

								    if (document.createEventObject){
											var evt = document.createEventObject();
											id_field.fireEvent('onchange', evt)
								    } else {
											var evt = document.createEvent("HTMLEvents");
											evt.initEvent("change", true, true);
											id_field.dispatchEvent(evt);
								    }

                    $(div.id.replace("_container","")).value = itemdata[2];
										$(div.id.replace("_container","")).focus();
                    $$(".in_ajax_select_active").each(function(item) { item.className = 'in_ajax_select'; });
                    $$(".ajax_select_popup").each(function(item) { item.style.display = "none"; });
										__prevent_dialog_handler_action = true;
										
										if ($(div.id.replace("_container","")+"_id").hasAttribute("js_filter_params")) {
											div.parentNode.removeChild(div);
										}
										Event.stop(event);
                  });
                });
              }
            },
            onFailure: function(transport) {
              show_ajax_error_dialog(transport);
            }
          });
        }
      );
    
      // trigger search...
      searchinput.value = "";
      if ($(div.id + "_searchimg").style.display == "none") {
        $(div.id + "_searchinput").style.width = ($(div.id + "_searchinput").offsetWidth - 26) + "px";
        $(div.id + "_searchimg").style.display = "inline";
      }
    }
    var target=$(target_id);
    target.style.display = "block";
    $(target_id + "_searchinput").focus();
    
    ref.className = 'in_ajax_select in_ajax_select_active';
  }
}
var dialog_handlers = new Array();
function register_dialog_handler (dialog, close_action, submit_action) {
	var existing_handler = false;
	dialog_handlers.each(function(item, ix) {
		if (item[0] == dialog) {
			dialog_handlers[ix][1] = close_action;
			dialog_handlers[ix][2] = submit_action;
			existing_handler = true;
		}
	});
	if (!existing_handler) {
		dialog_handlers[dialog_handlers.length] = new Array(dialog, close_action, submit_action);
	}
}
var __prevent_dialog_handler_action = false;
Event.observe(document, "dom:loaded", function() {
  convert_all_ajax_pulldowns();

	// Toetsen afhandelen (mits dialog geregistreerd is):
	//		ESC = dialoog sluiten
	//		ENTER = dialoog bevestigen
	Event.observe(document.body, "keyup", function(e) {
		if (!e) var e = window.event;
		if (e && (e.ctrlKey || e.altKey || e.metaKey)) return true;
		
		if (__prevent_dialog_handler_action) {
			__prevent_dialog_handler_action = false;
			return;
		}
		if (e.keyCode == 27) {
			dialog_handlers.each(function(item, ix) {
				if (item[0] && item[0].cfg && item[0].cfg.getProperty("visible")) {
					item[1]();
				}
			});
		}
		if (e.keyCode == 13) {
			dialog_handlers.each(function(item, ix) {
				if (item[0] && item[0].cfg && item[0].cfg.getProperty("visible")) {
					item[2]();
				}
			});
		}
	})


  // bij klikken op venster alle open
  // ajax_select-pulldowns sluiten
  Event.observe(document.body, "click", function() {
    $$(".in_ajax_select_active").each(function(item) {
      item.className = 'in_ajax_select';
    });
    $$(".ajax_select_popup").each(function(item) {
      item.style.display = "none";
    });
  })
});


function toggle_named_scope(ref, new_scope) {
	var button = ref.parentNode.parentNode;
	var container = button.parentNode;
	$(container).select(".yui-radio-button-checked").each(function(active_button) {
		active_button.className = active_button.className.replace(/yui-radio-button-checked/,"");
	});
	if ($('list_scope')) {
		$('list_scope').value = new_scope;
	}
	button.className = button.className + " yui-radio-button-checked";
}

function load_show_using_hash () {
	if (window.location.hash != "") {
		var id = window.location.hash.replace(/\#/,"");
		var show_url = $('list').select("table")[0].getAttribute("show_url").replace(/__ID__/, id);
		return crud_show(event, show_url, id);
	}
}

//
// i18n
//
function t(i18n_string, interpolations, default_value) {
	if (typeof(i18n_string) != "undefined") {
		var data = null;
		try { var data = i18n_strings[i18n_string]; } catch (e) { }
		if (data && typeof(data) == "object" && data.length == 2) {
			var str = data[0];
			data[1].each(function(interpolation) {
				if (interpolations && interpolations[interpolation]) {
					str = str.replace("{{" + interpolation + "}}", interpolations[interpolation]);
				}
			});
			return str;
		}
		if (data && (typeof(data) == "string" || typeof(data) == "object")) {
			return data;
		}
	}
	return default_value;
}