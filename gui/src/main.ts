import { AppComponent, BrandComponent, Connection, Settings } from '@ratiosolver/flick';
import { coco } from '@ratiosolver/coco';
import { Offcanvas as RAISEOffcanvas } from './offcanvas';
import './style.css'
import { Offcanvas } from 'bootstrap';

Settings.get_instance().load_settings({ ws_path: '/coco' });

const offcanvas_id = 'restart-offcanvas';

class RAISEBrandComponent extends BrandComponent {

  constructor() {
    super('Citizen Digital Twin', 'logo.jpg', 300, 32);
    this.node.id = 'raise-brand';
  }
}

class RAISEApp extends AppComponent {

  constructor() {
    super(new RAISEBrandComponent());

    const offcanvas = new RAISEOffcanvas(offcanvas_id);
    this.add_child(offcanvas);
    document.getElementById('raise-brand')?.addEventListener('click', (event) => {
      event.preventDefault();
      Offcanvas.getOrCreateInstance(document.getElementById(offcanvas_id)!).toggle();
    });

    Connection.get_instance().connect();
  }

  override received_message(message: any): void { coco.CoCo.get_instance().update_coco(message); }

  override connection_error(_error: any): void { this.toast('Connection error. Please try again later.'); }
}

new RAISEApp();