var isGrid = 0;
var isExpanded = 0;

function switchView(){
	var gb = document.getElementById("grid-button");
	var fb = document.getElementById("flat-button");

	if (isGrid) {
		removeClass(document.getElementById("primary"), "grid");
		isGrid = 0;
		addClass(fb, "selected");
		removeClass(gb, "selected");
	}else{
		addClass(document.getElementById("primary"), "grid");
		isGrid = 1;
		addClass(gb, "selected");
		removeClass(fb, "selected");
	};
}

// Show (of hide) a post when I click the title of a post
function expand(title){
	if (isExpanded) {
		document.body.removeChild(document.getElementById("expanded-post"));
		removeClass(document.body, "stop-scrolling");
		isExpanded = 0;
	}else{
		var thePost = title.parentElement;
		var theExpandedPostView = document.createElement("div");
		var thePostCloned = thePost.cloneNode(true);
		thePostCloned.setAttribute("onClick", "nothing(event)");
		theExpandedPostView.appendChild(thePostCloned);
		theExpandedPostView.id = "expanded-post";
		theExpandedPostView.setAttribute("onClick", "expand(this)");
		document.body.appendChild(theExpandedPostView);
		addClass(document.body, "stop-scrolling");
		isExpanded = 1;
	};
}

function nothing(event){
	if (!event) var event = window.event;
	event.stopPropagation();
}

function addClass(targetElement, classNameToAdd){
	targetElement.className = targetElement.className + " " + classNameToAdd;
}

function removeClass(targetElement, classNameToRemove){
	targetElement.className = targetElement.className.replace(classNameToRemove, "");
}


// まだひとつのtagずつしか対応してない。
// TODO: 複数のtagsを選択した時にもうまくいくようにする
function showTaggedPosts(element){
	if(element.className.match(/selected/)){
		displayTaggedPosts = "block";
		displayAllPosts = "block";
		removeClass(element, 'selected')
	}else{
		var oldSelection = element.parentElement.getElementsByClassName('selected');
		for (var i=0; i<oldSelection.length; i++) {
			removeClass(oldSelection[i], 'selected');
		}

		displayAllPosts = "none";
		displayTaggedPosts = "block";
		addClass(element, 'selected');
	}
	var allPosts = document.getElementsByClassName('post');
	for (var i=0; i<allPosts.length; i++) {
		allPosts[i].style.display = displayAllPosts;
	}

	var tagName = element.innerText;
	var taggedPosts = document.getElementsByClassName('tag-'+tagName);
	for(var i=0; i<taggedPosts.length; i++){
		taggedPosts[i].style.display = displayTaggedPosts;
	}
}
