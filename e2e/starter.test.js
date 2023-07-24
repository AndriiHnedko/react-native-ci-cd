describe('Example', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should have welcome screen', async () => {
    await expect(element(by.id('welcome'))).toBeVisible();
  });

  it('should have env info', async () => {
    await expect(element(by.id('env'))).toBeVisible();
    await expect(element(by.id('env.title'))).toHaveText('Env');
    await expect(element(by.id('env.children'))).toBeVisible();
  });

  it('should have learn more', async () => {
    await element(by.id('scroll_view')).scrollTo('bottom')
    await expect(element(by.id('learn_more'))).toBeVisible();
    await expect(element(by.id('learn_more.title'))).toBeVisible();
    await expect(element(by.id('learn_more.children'))).toBeVisible();
  });
});
