dojo.provide("ywesee.widget.edit.InputText");

dojo.require("dojo.event");
dojo.require("dojo.widget.*");
dojo.require("dojo.lfx.*");
dojo.require("dojo.style");
dojo.require("ywesee.widget.EditWidget");

dojo.widget.defineWidget(
	"dojo.widget.edit.InputText",
	ywesee.widget.EditWidget,
	{
		widgetType: "InputText",
		isContainer: false,

		// widget variables
		artobject_id: "",			
		value: "",
		css_class: "",
		update_url: "",
		field_key: "",
		className: "",

		// attach points
		containerNode: null,

		fillInTemplate: function(){
		},

	}
);
