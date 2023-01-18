package com.minkasu.twofasample;

import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;

import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.google.android.material.navigation.NavigationView;
import com.minkasu.android.twofa.enums.Minkasu2faOperationType;
import com.minkasu.android.twofa.sdk.Minkasu2faSDK;

import java.util.List;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {
    public static final String MERCHANT_CUSTOMER_ID = "C_1";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);
        hideItems();
        Menu nav_Menu = navigationView.getMenu();
        nav_Menu.performIdentifierAction(R.id.nav_auth_pay, 0);
    }

    @Override
    protected void onResume() {
        super.onResume();
        hideItems();
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    private void hideItems() {
        NavigationView navigationView = findViewById(R.id.nav_view);
        Menu nav_Menu = navigationView.getMenu();

        //Gets the list of Operations that is available according to the state of Minkasu 2FA SDK.
        List<Minkasu2faOperationType> operationTypes = Minkasu2faSDK.getAvailableMinkasu2faOperations(getApplicationContext());

        nav_Menu.findItem(R.id.nav_change_pin).setVisible(false);
        nav_Menu.findItem(R.id.nav_enablebiometrics).setVisible(false);
        nav_Menu.findItem(R.id.nav_disablebiometrics).setVisible(false);


        for (int i = 0; i < operationTypes.size(); i++) {
            MenuItem item;
            if (operationTypes.get(i) == Minkasu2faOperationType.CHANGE_PAYPIN) {
                item = nav_Menu.findItem(R.id.nav_change_pin).setVisible(true);
                //set custom title string for menu item
                item.setTitle(Minkasu2faOperationType.valueOf(Minkasu2faOperationType.CHANGE_PAYPIN));
            } else if (operationTypes.get(i) == Minkasu2faOperationType.ENABLE_BIOMETRICS) {
                item = nav_Menu.findItem(R.id.nav_enablebiometrics).setVisible(true);
                //set custom title string for menu item
                item.setTitle(Minkasu2faOperationType.valueOf(Minkasu2faOperationType.ENABLE_BIOMETRICS));
            } else if (operationTypes.get(i) == Minkasu2faOperationType.DISABLE_BIOMETRICS) {
                item = nav_Menu.findItem(R.id.nav_disablebiometrics).setVisible(true);
                //set custom title string for menu item
                item.setTitle(Minkasu2faOperationType.valueOf(Minkasu2faOperationType.DISABLE_BIOMETRICS));
            }
        }
    }

    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        popAllFragmentsInStack();
        if (id == R.id.nav_auth_pay) {
            getSupportFragmentManager().beginTransaction().replace(R.id.content_main, getAuthPayFragment(), "PayFragment").commit();
        } else if (id == R.id.nav_change_pin) {
            performMinkasu2faOperation(Minkasu2faOperationType.CHANGE_PAYPIN);
        } else if (id == R.id.nav_enablebiometrics) {
            performMinkasu2faOperation(Minkasu2faOperationType.ENABLE_BIOMETRICS);
        } else if (id == R.id.nav_disablebiometrics) {
            performMinkasu2faOperation(Minkasu2faOperationType.DISABLE_BIOMETRICS);
        }
        return true;
    }

    private void popAllFragmentsInStack() {
        FragmentManager fragmentManager = getSupportFragmentManager();
        int stack_size_1 = fragmentManager.getBackStackEntryCount();
        for (int i = 0; i < stack_size_1; i++) {
            fragmentManager.popBackStackImmediate();
        }
        int stack_size_2 = fragmentManager.getBackStackEntryCount();
        Log.i("MinkasuSDKActivity", "PopAllFramgents: stack size changed from " + stack_size_1
                + " to  " + stack_size_2);
    }

    private Fragment getAuthPayFragment() {
        Bundle args;
        AuthPayFragment fragment = new AuthPayFragment();
        args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    public void performMinkasu2faOperation(Minkasu2faOperationType operationType) {
        try {
            //Creating Minkasu 2FA SDK object to perform the selected menu action.
            Minkasu2faSDK minkasu2faSDKInstance = Minkasu2faSDK.create(MainActivity.this, operationType, MERCHANT_CUSTOMER_ID);
            minkasu2faSDKInstance.start();
        } catch (Exception e) {
            Log.i("Exception", e.toString());
        }
    }
}
