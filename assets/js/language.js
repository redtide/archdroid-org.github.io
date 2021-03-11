(function(){ // Don't execute code at global scope

// Set default user language if none chosen yet.
var default_lang=$("#language-menu").attr("data-default");
if(!localStorage.getItem("language")){
	localStorage.setItem("language", default_lang);
}

var page_loading=false;

// When visiting the homepage redirect to user chosen language.
var current_lang=localStorage.getItem("language");
if(location.pathname == "/"){
	if(current_lang != default_lang){
		location.href="/" + current_lang + "/";
		page_loading = true;
	}
}

if(current_lang != default_lang){
	$("[data-localize]").localize(
		"",
		{
			language: current_lang,
			pathPrefix: "/assets/localization"
		}
	);
}

// Redirect not found pages to default language or root path
if(!localStorage.getItem("redirections")){
	localStorage.setItem("redirections", 0);
}
if($("#page-not-found").length > 0){
	var redirections=localStorage.getItem("redirections");
	if(redirections >= 4){
		localStorage.setItem("redirections", 0);
	} else{
		redirections++;
		localStorage.setItem("redirections", redirections);

		var path_parts=location.pathname.split("/");
		if(path_parts[1] != default_lang){
			if(path_parts[1] == current_lang){
				path_parts[1] = default_lang;
				location.href = path_parts.join("/");
			} else{
				location.href = "/" + default_lang + location.pathname;
			}
			page_loading = true;
		} else{
			path_parts.splice(1, 1);
			location.href = path_parts.join("/");
			page_loading = true;
		}
	}
}

// Register user language of choice on language menu click.
$(document).ready(function(){
	if(!page_loading)
		$("body").css("visibility", "visible").hide().fadeIn("fast");

	$("#language-menu a").click(function(){
		localStorage.setItem("language", $(this).attr("data-lang"));
	});

	var language_image_parts=$("#language-image").attr("src").split("/");
	language_image_parts[language_image_parts.length-1] = current_lang + ".png";
	$("#language-image").attr("src", language_image_parts.join("/"));
});

})();
