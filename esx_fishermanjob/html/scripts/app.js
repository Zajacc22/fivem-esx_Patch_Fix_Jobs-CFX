(function(){

	let DefaultTpl = 
		'<div class="head">{{title}}</div>' +
			'<div class="menu-items">' + 
				'{{#items}}<div class="menu-item" data-value="{{value}}">{{label}}</div>{{/items}}' +
			'</div>'+
		'</div>'
	;

	let DefaultWithTypeAndCountTpl = 
		'<div class="head">{{title}}</div>' +
			'<div class="menu-items">' + 
				'{{#items}}<div class="menu-item" data-value="{{value}}" data-remove-on-select="{{removeOnSelect}}" data-type="{{type}}" data-count="{{count}}">{{label}}</div>{{/items}}' +
			'</div>'+
		'</div>'
	;

	let menus = {

		cloakroom : {
		  title     : 'Vestiaire',
		 	visible   : false,
		 	current   : 0,
		 	hasControl: true,
		 	template  : DefaultTpl,

		  items: [
		  	{label: 'Tenue civil',   value: 'citizen_wear'},
		  	{label: 'Tenue pêcheur', value: 'fisherman_wear'},
		  ]
		},

		boatspawner : {
		  title     : 'Véhicule',
		 	visible   : false,
		 	current   : 0,
		 	hasControl: true,
		 	template  : DefaultTpl,

		  items: [
		  	{label: 'Bâteau de pêche', value: 'tug'},
		  ]
		},

		truckspawner : {
		  title     : 'Véhicule',
		 	visible   : false,
		 	current   : 0,
		 	hasControl: true,
		 	template  : DefaultTpl,

		  items: [
		  	{label: 'Véhicule de livraison', value: 'mule'},
		  ]
		},

		fishing : {
		  title     : 'Pêcher',
		 	visible   : false,
		 	current   : 0,
		 	hasControl: false,
		 	template  : DefaultTpl,

		  items: []
		},

		delivery : {
		  title     : 'Vendre poisson',
		 	visible   : false,
		 	current   : 0,
		 	hasControl: false,
		 	template  : DefaultTpl,

		  items: []
		}
	}

	let renderMenus = function(){
		for(let k in menus){

			let elem = $('#menu_' + k);

			elem.html(Mustache.render(menus[k].template, menus[k]));

			if(menus[k].visible)
				elem.show();
			else
				elem.hide();

		}
	}

	let showMenu = function(menu){

		currentMenu = menu;

		for(let k in menus)
			menus[k].visible = false;

		menus[menu].visible = true;

		renderMenus();

		if(menus[currentMenu].items.length > 0){

			$('#menu_' + currentMenu + ' .menu-item').removeClass('selected');
			$('#menu_' + currentMenu + ' .menu-item:eq(0)').addClass('selected');

			menus[currentMenu].current = 0;
			currentVal                 = menus[currentMenu].items[menus[currentMenu].current].value;
			currentType                = $('#menu_' + currentMenu + ' .menu-item:eq(0)').data('type');
			currentCount               = $('#menu_' + currentMenu + ' .menu-item:eq(0)').data('count');
		}
		
		$('#ctl_return').show();

		isMenuOpen        = true
		isShowingControls = false
	}

	let hideMenus = function(){
		
		for(let k in menus)
			menus[k].visible = false;

		renderMenus();
		isMenuOpen = false;
	}

	let showControl = function(control){

		hideControls();
		$('#ctl_' + control).show();
		isShowingControls = true;
		currentControl    = control;
	}

	let hideControls = function(){

		for(let k in menus)
			$('#ctl_' + k).hide();

		$('#ctl_return').hide();

		isShowingControls = false;
	}

	let isMenuOpen        = false
	let isShowingControls = false;
	let currentMenu       = null;
	let currentControl    = null;
	let currentVal        = null;
	let currentType       = null;
	let currentCount      = null;

	renderMenus();

	window.onData = function(data){

		if(data.showControls === true){
			currentMenu = data.controls;
			showControl(data.controls);
		}

		if(data.showControls === false){
			hideControls();
		}

		if(data.showMenu === true){
			hideControls();

			if(data.items)
				menus[data.menu].items = data.items

			showMenu(data.menu);
		}

		if(data.showMenu === false){
			hideMenus();
		}

		if(data.move && isMenuOpen){

			if(data.move == 'UP'){
				if(menus[currentMenu].current > 0)
					menus[currentMenu].current--;
			}

			if(data.move == 'DOWN'){
				
				let max = $('#menu_' + currentMenu + ' .menu-item').length;

				if(menus[currentMenu].current < max - 1)
					menus[currentMenu].current++;
			}

			$('#menu_' + currentMenu + ' .menu-item').removeClass('selected');
			$('#menu_' + currentMenu + ' .menu-item:eq(' + menus[currentMenu].current + ')').addClass('selected');

			currentVal   = menus[currentMenu].items[menus[currentMenu].current].value;
			currentType  = $('#menu_' + currentMenu + ' .menu-item:eq(' + menus[currentMenu].current + ')').data('type');
			currentCount = $('#menu_' + currentMenu + ' .menu-item:eq(' + menus[currentMenu].current + ')').data('count');
		}

		if(data.enterPressed){

			if(isShowingControls){

				$.post('http://esx_fishermanjob/select_control', JSON.stringify({
					control: currentControl,
				}))

				hideControls();
				showMenu(currentMenu);
			
			} else if(isMenuOpen) {

				$.post('http://esx_fishermanjob/select', JSON.stringify({
					menu : currentMenu,
					val  : currentVal,
					type : currentType,
					count: currentCount
				}))

				let elem = $('#menu_' + currentMenu + ' .menu-item.selected')

				if(elem.data('remove-on-select') == true){
					
					elem.remove();

					menus[currentMenu].items.splice(menus[currentMenu].current, 1)
					menus[currentMenu].current = 0;

					$('#menu_' + currentMenu + ' .menu-item').removeClass('selected');
					$('#menu_' + currentMenu + ' .menu-item:eq(0)').addClass('selected');
					
					currentVal   = menus[currentMenu].items[0].value;
					currentType  = $('#menu_' + currentMenu + ' .menu-item:eq(0)').data('type');
					currentCount = $('#menu_' + currentMenu + ' .menu-item:eq(0)').data('count');
				}

			} 

		}

		if(data.backspacePressed){

			if(isMenuOpen && currentMenu == 'cloakroom'){
				hideMenus();
				$('#ctl_return').hide();
			}

			if(isMenuOpen && currentMenu == 'boatspawner'){
				hideMenus();
				$('#ctl_return').hide();
			}

			if(isMenuOpen && currentMenu == 'truckspawner'){
				hideMenus();
				$('#ctl_return').hide();
			}
		}

	}

	window.onload = function(e){ window.addEventListener('message', function(event){ onData(event.data) }); }

})()