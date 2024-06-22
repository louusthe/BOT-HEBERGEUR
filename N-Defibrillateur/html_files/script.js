window.onload = function() {
    document.body.style.display = 'none';
}

var defibrillatorSound = new Audio('defibrillateur.mp3');
defibrillatorSound.volume = 0.3;

window.addEventListener('message', function(event) {
    if (event.data.action == 'startSong') {
        console.log("Starting song or sound effect...");
        defibrillatorSound.play(); // Jouer le son
    }
});