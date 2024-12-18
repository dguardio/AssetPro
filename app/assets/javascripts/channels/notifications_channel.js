import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("Connected to notifications channel")
  },

  disconnected() {
    console.log("Disconnected from notifications channel")
  },

  received(data) {
    if (typeof $.notify === 'function') {
      $.notify({
        title: data.title,
        message: data.message,
        url: data.url,
        target: '_self',
        icon: 'notifications'
      }, {
        type: 'info',
        delay: 5000,
        placement: {
          from: 'top',
          align: 'right'
        },
        animate: {
          enter: 'animated fadeInDown',
          exit: 'animated fadeOutUp'
        }
      });
    } else {
      console.error('$.notify is not available');
    }
  }
}); 