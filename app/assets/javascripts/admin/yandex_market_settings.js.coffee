$ ->
	cat = $ '#preferences_cat_taxonomy_id'
	cat_list = $ '#preferences_cat_list'
	cat_holder = $ '#ym_cats_holder'
	cat_switch = $ '#cat_filter_switch input:checkbox'
	
	($ '#ym_do_export').click (e) ->
		e.preventDefault()
		$.post "/admin/yandex_market_settings/export", (data) ->
			($ '#wrapper .flash').detach()
			($ '#wrapper').prepend("<div class='flash success'>#{data}</div>")
	
	cat_holder.on 'click', 'input:checkbox', -> recount_checked()
	
	cat_switch.click ->
		if this.checked
			load_cats(cat.val())
		else
			cat_list.val('')
			cat_holder.empty()
	
	cat.change ->
		cat_list.val('')
		load_cats(cat.val()) if cat_switch.is(':checked')
		
	load_cats = (taxonomy_id) ->
		$.getJSON "/admin/yandex_market_settings/taxonomy/#{taxonomy_id}", (data) -> cat_holder.html(data.html)
		
	recount_checked = ->
		cat_list.val ($.map cat_holder.find('input:checked'), (n, i) -> n.value).join(',')