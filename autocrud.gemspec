# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{autocrud}
  s.version = "3.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["LICO Innovations"]
  s.date = %q{2010-11-22}
  s.description = %q{Rails plugin for the automation of CRUD tasks}
  s.email = %q{info@lico.nl}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "Gemfile",
     "Gemfile.lock",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "app/views/autocrud/_details.html.haml",
     "app/views/autocrud/_form.html.haml",
     "app/views/autocrud/_list.html.haml",
     "app/views/autocrud/edit.html.haml",
     "app/views/autocrud/index.html.haml",
     "app/views/autocrud/new.html.haml",
     "app/views/autocrud/show.html.haml",
     "assets/ckeditor/ckeditor.js",
     "assets/ckeditor/config.js",
     "assets/ckeditor/images/spacer.gif",
     "assets/ckeditor/lang/_languages.js",
     "assets/ckeditor/lang/_translationstatus.txt",
     "assets/ckeditor/lang/af.js",
     "assets/ckeditor/lang/ar.js",
     "assets/ckeditor/lang/bg.js",
     "assets/ckeditor/lang/bn.js",
     "assets/ckeditor/lang/bs.js",
     "assets/ckeditor/lang/ca.js",
     "assets/ckeditor/lang/cs.js",
     "assets/ckeditor/lang/da.js",
     "assets/ckeditor/lang/de.js",
     "assets/ckeditor/lang/el.js",
     "assets/ckeditor/lang/en-au.js",
     "assets/ckeditor/lang/en-ca.js",
     "assets/ckeditor/lang/en-uk.js",
     "assets/ckeditor/lang/en.js",
     "assets/ckeditor/lang/eo.js",
     "assets/ckeditor/lang/es.js",
     "assets/ckeditor/lang/et.js",
     "assets/ckeditor/lang/eu.js",
     "assets/ckeditor/lang/fa.js",
     "assets/ckeditor/lang/fi.js",
     "assets/ckeditor/lang/fo.js",
     "assets/ckeditor/lang/fr-ca.js",
     "assets/ckeditor/lang/fr.js",
     "assets/ckeditor/lang/gl.js",
     "assets/ckeditor/lang/gu.js",
     "assets/ckeditor/lang/he.js",
     "assets/ckeditor/lang/hi.js",
     "assets/ckeditor/lang/hr.js",
     "assets/ckeditor/lang/hu.js",
     "assets/ckeditor/lang/is.js",
     "assets/ckeditor/lang/it.js",
     "assets/ckeditor/lang/ja.js",
     "assets/ckeditor/lang/km.js",
     "assets/ckeditor/lang/ko.js",
     "assets/ckeditor/lang/lt.js",
     "assets/ckeditor/lang/lv.js",
     "assets/ckeditor/lang/mn.js",
     "assets/ckeditor/lang/ms.js",
     "assets/ckeditor/lang/nb.js",
     "assets/ckeditor/lang/nl.js",
     "assets/ckeditor/lang/no.js",
     "assets/ckeditor/lang/pl.js",
     "assets/ckeditor/lang/pt-br.js",
     "assets/ckeditor/lang/pt.js",
     "assets/ckeditor/lang/ro.js",
     "assets/ckeditor/lang/ru.js",
     "assets/ckeditor/lang/sk.js",
     "assets/ckeditor/lang/sl.js",
     "assets/ckeditor/lang/sr-latn.js",
     "assets/ckeditor/lang/sr.js",
     "assets/ckeditor/lang/sv.js",
     "assets/ckeditor/lang/th.js",
     "assets/ckeditor/lang/tr.js",
     "assets/ckeditor/lang/uk.js",
     "assets/ckeditor/lang/vi.js",
     "assets/ckeditor/lang/zh-cn.js",
     "assets/ckeditor/lang/zh.js",
     "assets/ckeditor/plugins/about/dialogs/about.js",
     "assets/ckeditor/plugins/about/dialogs/logo_ckeditor.png",
     "assets/ckeditor/plugins/about/plugin.js",
     "assets/ckeditor/plugins/basicstyles/plugin.js",
     "assets/ckeditor/plugins/blockquote/plugin.js",
     "assets/ckeditor/plugins/button/plugin.js",
     "assets/ckeditor/plugins/clipboard/dialogs/paste.js",
     "assets/ckeditor/plugins/clipboard/plugin.js",
     "assets/ckeditor/plugins/colorbutton/plugin.js",
     "assets/ckeditor/plugins/colordialog/dialogs/colordialog.js",
     "assets/ckeditor/plugins/colordialog/plugin.js",
     "assets/ckeditor/plugins/contextmenu/plugin.js",
     "assets/ckeditor/plugins/dialog/dialogDefinition.js",
     "assets/ckeditor/plugins/dialog/plugin.js",
     "assets/ckeditor/plugins/dialogui/plugin.js",
     "assets/ckeditor/plugins/domiterator/plugin.js",
     "assets/ckeditor/plugins/editingblock/plugin.js",
     "assets/ckeditor/plugins/elementspath/plugin.js",
     "assets/ckeditor/plugins/enterkey/plugin.js",
     "assets/ckeditor/plugins/entities/plugin.js",
     "assets/ckeditor/plugins/fakeobjects/plugin.js",
     "assets/ckeditor/plugins/filebrowser/plugin.js",
     "assets/ckeditor/plugins/find/dialogs/find.js",
     "assets/ckeditor/plugins/find/plugin.js",
     "assets/ckeditor/plugins/flash/dialogs/flash.js",
     "assets/ckeditor/plugins/flash/images/placeholder.png",
     "assets/ckeditor/plugins/flash/plugin.js",
     "assets/ckeditor/plugins/floatpanel/plugin.js",
     "assets/ckeditor/plugins/font/plugin.js",
     "assets/ckeditor/plugins/format/plugin.js",
     "assets/ckeditor/plugins/forms/dialogs/button.js",
     "assets/ckeditor/plugins/forms/dialogs/checkbox.js",
     "assets/ckeditor/plugins/forms/dialogs/form.js",
     "assets/ckeditor/plugins/forms/dialogs/hiddenfield.js",
     "assets/ckeditor/plugins/forms/dialogs/radio.js",
     "assets/ckeditor/plugins/forms/dialogs/select.js",
     "assets/ckeditor/plugins/forms/dialogs/textarea.js",
     "assets/ckeditor/plugins/forms/dialogs/textfield.js",
     "assets/ckeditor/plugins/forms/plugin.js",
     "assets/ckeditor/plugins/horizontalrule/plugin.js",
     "assets/ckeditor/plugins/htmldataprocessor/plugin.js",
     "assets/ckeditor/plugins/htmlwriter/plugin.js",
     "assets/ckeditor/plugins/iframedialog/plugin.js",
     "assets/ckeditor/plugins/image/dialogs/image.js",
     "assets/ckeditor/plugins/image/plugin.js",
     "assets/ckeditor/plugins/indent/plugin.js",
     "assets/ckeditor/plugins/justify/plugin.js",
     "assets/ckeditor/plugins/keystrokes/plugin.js",
     "assets/ckeditor/plugins/link/dialogs/anchor.js",
     "assets/ckeditor/plugins/link/dialogs/link.js",
     "assets/ckeditor/plugins/link/images/anchor.gif",
     "assets/ckeditor/plugins/link/plugin.js",
     "assets/ckeditor/plugins/list/plugin.js",
     "assets/ckeditor/plugins/listblock/plugin.js",
     "assets/ckeditor/plugins/maximize/plugin.js",
     "assets/ckeditor/plugins/menu/plugin.js",
     "assets/ckeditor/plugins/menubutton/plugin.js",
     "assets/ckeditor/plugins/newpage/plugin.js",
     "assets/ckeditor/plugins/pagebreak/images/pagebreak.gif",
     "assets/ckeditor/plugins/pagebreak/plugin.js",
     "assets/ckeditor/plugins/panel/plugin.js",
     "assets/ckeditor/plugins/panelbutton/plugin.js",
     "assets/ckeditor/plugins/pastefromword/dialogs/pastefromword.js",
     "assets/ckeditor/plugins/pastefromword/plugin.js",
     "assets/ckeditor/plugins/pastetext/dialogs/pastetext.js",
     "assets/ckeditor/plugins/pastetext/plugin.js",
     "assets/ckeditor/plugins/popup/plugin.js",
     "assets/ckeditor/plugins/preview/plugin.js",
     "assets/ckeditor/plugins/print/plugin.js",
     "assets/ckeditor/plugins/removeformat/plugin.js",
     "assets/ckeditor/plugins/resize/plugin.js",
     "assets/ckeditor/plugins/richcombo/plugin.js",
     "assets/ckeditor/plugins/save/plugin.js",
     "assets/ckeditor/plugins/scayt/dialogs/options.js",
     "assets/ckeditor/plugins/scayt/dialogs/toolbar.css",
     "assets/ckeditor/plugins/scayt/plugin.js",
     "assets/ckeditor/plugins/selection/plugin.js",
     "assets/ckeditor/plugins/showblocks/images/block_address.png",
     "assets/ckeditor/plugins/showblocks/images/block_blockquote.png",
     "assets/ckeditor/plugins/showblocks/images/block_div.png",
     "assets/ckeditor/plugins/showblocks/images/block_h1.png",
     "assets/ckeditor/plugins/showblocks/images/block_h2.png",
     "assets/ckeditor/plugins/showblocks/images/block_h3.png",
     "assets/ckeditor/plugins/showblocks/images/block_h4.png",
     "assets/ckeditor/plugins/showblocks/images/block_h5.png",
     "assets/ckeditor/plugins/showblocks/images/block_h6.png",
     "assets/ckeditor/plugins/showblocks/images/block_p.png",
     "assets/ckeditor/plugins/showblocks/images/block_pre.png",
     "assets/ckeditor/plugins/showblocks/plugin.js",
     "assets/ckeditor/plugins/smiley/dialogs/smiley.js",
     "assets/ckeditor/plugins/smiley/images/angel_smile.gif",
     "assets/ckeditor/plugins/smiley/images/angry_smile.gif",
     "assets/ckeditor/plugins/smiley/images/broken_heart.gif",
     "assets/ckeditor/plugins/smiley/images/confused_smile.gif",
     "assets/ckeditor/plugins/smiley/images/cry_smile.gif",
     "assets/ckeditor/plugins/smiley/images/devil_smile.gif",
     "assets/ckeditor/plugins/smiley/images/embaressed_smile.gif",
     "assets/ckeditor/plugins/smiley/images/envelope.gif",
     "assets/ckeditor/plugins/smiley/images/heart.gif",
     "assets/ckeditor/plugins/smiley/images/kiss.gif",
     "assets/ckeditor/plugins/smiley/images/lightbulb.gif",
     "assets/ckeditor/plugins/smiley/images/omg_smile.gif",
     "assets/ckeditor/plugins/smiley/images/regular_smile.gif",
     "assets/ckeditor/plugins/smiley/images/sad_smile.gif",
     "assets/ckeditor/plugins/smiley/images/shades_smile.gif",
     "assets/ckeditor/plugins/smiley/images/teeth_smile.gif",
     "assets/ckeditor/plugins/smiley/images/thumbs_down.gif",
     "assets/ckeditor/plugins/smiley/images/thumbs_up.gif",
     "assets/ckeditor/plugins/smiley/images/tounge_smile.gif",
     "assets/ckeditor/plugins/smiley/images/whatchutalkingabout_smile.gif",
     "assets/ckeditor/plugins/smiley/images/wink_smile.gif",
     "assets/ckeditor/plugins/smiley/plugin.js",
     "assets/ckeditor/plugins/sourcearea/plugin.js",
     "assets/ckeditor/plugins/specialchar/dialogs/specialchar.js",
     "assets/ckeditor/plugins/specialchar/plugin.js",
     "assets/ckeditor/plugins/styles/plugin.js",
     "assets/ckeditor/plugins/stylescombo/plugin.js",
     "assets/ckeditor/plugins/stylescombo/styles/default.js",
     "assets/ckeditor/plugins/tab/plugin.js",
     "assets/ckeditor/plugins/table/dialogs/table.js",
     "assets/ckeditor/plugins/table/plugin.js",
     "assets/ckeditor/plugins/tabletools/dialogs/tableCell.js",
     "assets/ckeditor/plugins/tabletools/plugin.js",
     "assets/ckeditor/plugins/templates/dialogs/templates.js",
     "assets/ckeditor/plugins/templates/plugin.js",
     "assets/ckeditor/plugins/templates/templates/default.js",
     "assets/ckeditor/plugins/templates/templates/images/template1.gif",
     "assets/ckeditor/plugins/templates/templates/images/template2.gif",
     "assets/ckeditor/plugins/templates/templates/images/template3.gif",
     "assets/ckeditor/plugins/toolbar/plugin.js",
     "assets/ckeditor/plugins/uicolor/dialogs/uicolor.js",
     "assets/ckeditor/plugins/uicolor/lang/en.js",
     "assets/ckeditor/plugins/uicolor/plugin.js",
     "assets/ckeditor/plugins/uicolor/uicolor.gif",
     "assets/ckeditor/plugins/uicolor/yui/assets/hue_bg.png",
     "assets/ckeditor/plugins/uicolor/yui/assets/hue_thumb.png",
     "assets/ckeditor/plugins/uicolor/yui/assets/picker_mask.png",
     "assets/ckeditor/plugins/uicolor/yui/assets/picker_thumb.png",
     "assets/ckeditor/plugins/uicolor/yui/assets/yui.css",
     "assets/ckeditor/plugins/uicolor/yui/yui.js",
     "assets/ckeditor/plugins/undo/plugin.js",
     "assets/ckeditor/plugins/wsc/dialogs/ciframe.html",
     "assets/ckeditor/plugins/wsc/dialogs/tmpFrameset.html",
     "assets/ckeditor/plugins/wsc/dialogs/wsc.css",
     "assets/ckeditor/plugins/wsc/dialogs/wsc.js",
     "assets/ckeditor/plugins/wsc/plugin.js",
     "assets/ckeditor/plugins/wysiwygarea/plugin.js",
     "assets/ckeditor/skins/kama/dialog.css",
     "assets/ckeditor/skins/kama/editor.css",
     "assets/ckeditor/skins/kama/icons.png",
     "assets/ckeditor/skins/kama/images/dialog_sides.gif",
     "assets/ckeditor/skins/kama/images/dialog_sides.png",
     "assets/ckeditor/skins/kama/images/dialog_sides_rtl.png",
     "assets/ckeditor/skins/kama/images/mini.gif",
     "assets/ckeditor/skins/kama/images/noimage.png",
     "assets/ckeditor/skins/kama/images/sprites.png",
     "assets/ckeditor/skins/kama/images/sprites_ie6.png",
     "assets/ckeditor/skins/kama/images/toolbar_start.gif",
     "assets/ckeditor/skins/kama/skin.js",
     "assets/ckeditor/skins/kama/templates.css",
     "assets/ckeditor/skins/office2003/dialog.css",
     "assets/ckeditor/skins/office2003/editor.css",
     "assets/ckeditor/skins/office2003/icons.png",
     "assets/ckeditor/skins/office2003/images/dialog_sides.gif",
     "assets/ckeditor/skins/office2003/images/dialog_sides.png",
     "assets/ckeditor/skins/office2003/images/dialog_sides_rtl.png",
     "assets/ckeditor/skins/office2003/images/mini.gif",
     "assets/ckeditor/skins/office2003/images/noimage.png",
     "assets/ckeditor/skins/office2003/images/sprites.png",
     "assets/ckeditor/skins/office2003/images/sprites_ie6.png",
     "assets/ckeditor/skins/office2003/skin.js",
     "assets/ckeditor/skins/office2003/templates.css",
     "assets/ckeditor/skins/v2/dialog.css",
     "assets/ckeditor/skins/v2/editor.css",
     "assets/ckeditor/skins/v2/icons.png",
     "assets/ckeditor/skins/v2/images/dialog_sides.gif",
     "assets/ckeditor/skins/v2/images/dialog_sides.png",
     "assets/ckeditor/skins/v2/images/dialog_sides_rtl.png",
     "assets/ckeditor/skins/v2/images/mini.gif",
     "assets/ckeditor/skins/v2/images/noimage.png",
     "assets/ckeditor/skins/v2/images/sprites.png",
     "assets/ckeditor/skins/v2/images/sprites_ie6.png",
     "assets/ckeditor/skins/v2/images/toolbar_start.gif",
     "assets/ckeditor/skins/v2/skin.js",
     "assets/ckeditor/skins/v2/templates.css",
     "assets/ckeditor/themes/default/theme.js",
     "assets/images/add.png",
     "assets/images/calendar.png",
     "assets/images/control_end.png",
     "assets/images/control_next.png",
     "assets/images/control_prev.png",
     "assets/images/control_start.png",
     "assets/images/cross.png",
     "assets/images/delete.png",
     "assets/images/find.png",
     "assets/images/help.png",
     "assets/images/loading.gif",
     "assets/images/magnifier.png",
     "assets/images/menu-button-arrow-disabled.png",
     "assets/images/menu-button-arrow.png",
     "assets/images/menu_active.jpg",
     "assets/images/resultset_next.png",
     "assets/images/resultset_previous.png",
     "assets/images/sidebar_title.jpg",
     "assets/images/sort_asc.png",
     "assets/images/sort_desc.png",
     "assets/images/spinner.gif",
     "assets/images/split-button-arrow-active.png",
     "assets/images/split-button-arrow-disabled.png",
     "assets/images/split-button-arrow-focus.png",
     "assets/images/split-button-arrow-hover.png",
     "assets/images/sprite.png",
     "assets/images/tick.png",
     "assets/images/title.jpg",
     "assets/stylesheets/autocrud.css",
     "autocrud.gemspec",
     "lib/autocrud.rb",
     "lib/autocrud/controller.rb",
     "lib/autocrud/helper.rb",
     "lib/tasks/i18n.rake"
  ]
  s.homepage = %q{http://lico.nl/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Rails plugin for the automation of CRUD tasks}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<haml>, ["~> 3.0.21"])
    else
      s.add_dependency(%q<haml>, ["~> 3.0.21"])
    end
  else
    s.add_dependency(%q<haml>, ["~> 3.0.21"])
  end
end

