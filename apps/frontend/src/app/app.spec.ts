import { TestBed } from '@angular/core/testing';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { App } from './app';
import { NxWelcome } from './nx-welcome';

describe('App', () => {
  let httpMock: HttpTestingController;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [App, NxWelcome],
      providers: [provideHttpClientTesting(),],
    }).compileComponents();

    httpMock = TestBed.inject(HttpTestingController);
  });

  it('should render title', async () => {
    const fixture = TestBed.createComponent(App);

    fixture.detectChanges();

    httpMock.expectOne(process.env['NX_API_URL'] ?? '').flush({ message: 'Hello API' });

    await fixture.whenStable();

    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('h1')?.textContent).toContain(
      'Welcome frontend',
    );
  });

  afterEach(() => {
    httpMock.verify();
  });
});
