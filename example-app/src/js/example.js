import { Video } from 'capacitor-plugin-video';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    Video.echo({ value: inputValue })
}
