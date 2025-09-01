import { AppComponent, BrandComponent, Connection, Settings } from '@ratiosolver/flick';
import { coco } from '@ratiosolver/coco';
import { Offcanvas } from './offcanvas';
import './style.css'

Settings.get_instance().load_settings({ ws_path: '/coco' });

const offcanvas_id = 'restart-offcanvas';

class RAISEApp extends AppComponent {

  constructor() {
    super();

    // Create and add brand element
    this.navbar.add_child(new BrandComponent('Citizen Digital Twin', 'logo.jpg', 300, 32, offcanvas_id));

    this.add_child(new Offcanvas(offcanvas_id));

    Connection.get_instance().connect();
  }

  override received_message(message: any): void { coco.CoCo.get_instance().update_coco(message); }

  override connection_error(_error: any): void { this.toast('Connection error. Please try again later.'); }
}

new RAISEApp();