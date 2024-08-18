let meterStarted = false;

const updateMeter = (meterData) => {
  $("#total-price").html("Rp " + meterData.currentFare.toFixed(0));
  $("#total-distance").html(
    (meterData.distanceTraveled).toFixed(2) + " mi"
  );
};

const resetMeter = () => {
  $("#total-price").html("Rp 0");
  $("#total-distance").html("0.00 mi");
};

const toggleMeter = (enabled) => {
  if (enabled) {
    $(".toggle-meter-btn").html("<p>Hidup</p>");
    $(".toggle-meter-btn p").css({ color: "rgb(51, 160, 37)" });
  } else {
    $(".toggle-meter-btn").html("<p>Mati</p>");
    $(".toggle-meter-btn p").css({ color: "rgb(231, 30, 37)" });
  }
};

const meterToggle = () => {
  if (!meterStarted) {
    $.post(
      `https://${GetParentResourceName()}/enableMeter`,
      JSON.stringify({
        enabled: true,
      })
    );
    toggleMeter(true);
    meterStarted = true;
  } else {
    $.post(
      `https://${GetParentResourceName()}/enableMeter`,
      JSON.stringify({
        enabled: false,
      })
    );
    toggleMeter(false);
    meterStarted = false;
  }
};

const openMeter = (meterData) => {
  $(".container").fadeIn(150);
  $("#total-price-per-100m").html("Rp " + meterData.defaultPrice.toFixed(0));
};

const closeMeter = () => {
  $(".container").fadeOut(150);
};

$(document).ready(function () {
  $(".container").hide();
  window.addEventListener("message", (event) => {
    const eventData = event.data;
    switch (eventData.action) {
      case "openMeter":
        if (eventData.toggle) {
          openMeter(eventData.meterData);
        } else {
          closeMeter();
        }
        break;
      case "toggleMeter":
        meterToggle();
        break;
      case "updateMeter":
        updateMeter(eventData.meterData);
        break;
      case "resetMeter":
        resetMeter();
        break;
      default:
        break;
    }
  });
});
