$(document).ready(function(){
	let actionContainer = $("#actionmenu");
	let actionButton = $("#actionbutton");
	let idlecontainer = $("#idle");
	let uber = $(".faixa");
	let uberlogo = $(".uber-logo");
 
	window.addEventListener("message",function(event){
		let item = event.data;
		switch(item.action){
			case "showMenu":
				actionButton.fadeIn(10);
				actionContainer.fadeIn(10);
				idlecontainer.fadeIn(10);
				uber.fadeIn(300);
				uberlogo.fadeIn(300);
				updateScreen(item.state);
			break;

			case "hideMenu":
				actionButton.fadeOut(10);
				actionContainer.fadeOut(10);
				idlecontainer.fadeOut(10);
				uber.fadeOut(10);
			break;
		}
	});
});

const formatarNumero = (n) => {
	var n = n.toString();
	var r = '';
	var x = 0;

	for (var i = n.length; i > 0; i--) {
		r += n.substr(i - 1, 1) + (x == 2 && i != 1 ? '.' : '');
		x = x == 2 ? 0 : x + 1;
	}

	return r.split('').reverse().join('');
}

const carregarMenu = (name) => {
	return new Promise((resolve) => {
		$("#inicio").load(name+".html",function(){
			resolve();
		});
	});
}

const updateScreen = (state) => {
	if(state == 0) {
		$('.faixa').animate({height: "80px"}, 300);
		$('.uber-logo').animate({height: "500px"}, 300);
		$('#idle').html(`
			<span class="texto">Buscando passageiros...</span>
			<div class="lupa"></div>`
		)
	} else if(state == 1) {
		$('.faixa').animate({height: "0px"}, 400);
		$('.uber-logo').animate({height: "0px"}, 400);
		$('#idle').html(`
			<span class="texto2">Passageiro encontrado!</span>
			<div class="icon"></div>
			<div class="botao"><span class="ch-text">ACEITAR</span></div>`
		)
	}  else if(state == 2) {
		$('.faixa').animate({height: "80px"}, 300);
		$('.uber-logo').animate({height: "500px"}, 300);
		$('#idle').html(`
			<span class="texto3">Vá até o passageiro e leve-o ao seu destino</span>
			<div class="arrow"></div>
		`)
	}
}
