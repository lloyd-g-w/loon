open! Core
open Bonsai_web_test

let%expect_test "login-01, in full" =
  let handle = Render.handle Loon_blocks.Login_01.view in
  Handle.show handle;
  [%expect
    {|
    <div class="flex items-center justify-center md:p-10 min-h-svh p-6 w-full">
      <div class="max-w-sm w-full">
        <div class="flex flex-col gap-6">
          <div data-slot="card"
               class="bg-card border flex flex-col gap-6 py-6 rounded-xl shadow-sm text-card-foreground">
            <div data-slot="card-header"
                 class="@container/card-header [.border-b]:pb-6 auto-rows-min gap-2 grid grid-rows-[auto_auto] has-data-[slot=card-action]:grid-cols-[1fr_auto] items-start px-6">
              <div data-slot="card-title" class="font-semibold leading-none"> Login to your account </div>
              <div data-slot="card-description" class="text-muted-foreground text-sm"> Enter your email below to login to your account </div>
            </div>
            <div data-slot="card-content" class="px-6">
              <form>
                <div data-slot="field-group"
                     class="@container/field-group [&>[data-slot=field-group]]:gap-4 data-[slot=checkbox-group]:gap-3 flex flex-col gap-7 group/field-group w-full">
                  <div role="group"
                       data-slot="field"
                       data-orientation="vertical"
                       class="[&>*]:w-full [&>.sr-only]:w-auto data-[invalid=true]:text-destructive flex flex-col gap-3 group/field w-full">
                    <label data-slot="field-label"
                           for="email"
                           class="[&>*]:data-[slot=field]:p-4 dark:has-data-[state=checked]:bg-primary/10 flex font-medium gap-2 group-data-[disabled=true]/field:opacity-50 group-data-[disabled=true]:opacity-50 group-data-[disabled=true]:pointer-events-none group/field-label has-[>[data-slot=field]]:border has-[>[data-slot=field]]:flex-col has-[>[data-slot=field]]:rounded-md has-[>[data-slot=field]]:w-full has-data-[state=checked]:bg-primary/5 has-data-[state=checked]:border-primary items-center leading-snug peer-disabled:cursor-not-allowed peer-disabled:opacity-50 peer/field-label select-none text-sm w-fit"
                           @on_mousedown> Email </label>
                    <input type="email"
                           data-slot="input"
                           id="email"
                           placeholder="m@example.com"
                           required=""
                           class="aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-transparent border border-input dark:aria-invalid:ring-destructive/40 dark:bg-input/30 disabled:cursor-not-allowed disabled:opacity-50 disabled:pointer-events-none file:bg-transparent file:border-0 file:font-medium file:h-7 file:inline-flex file:text-foreground file:text-sm focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 h-9 md:text-sm min-w-0 outline-none placeholder:text-muted-foreground px-3 py-1 rounded-md selection:bg-primary selection:text-primary-foreground shadow-xs text-base transition-[color,box-shadow] w-full"/>
                  </div>
                  <div role="group"
                       data-slot="field"
                       data-orientation="vertical"
                       class="[&>*]:w-full [&>.sr-only]:w-auto data-[invalid=true]:text-destructive flex flex-col gap-3 group/field w-full">
                    <div class="flex items-center">
                      <label data-slot="field-label"
                             for="password"
                             class="[&>*]:data-[slot=field]:p-4 dark:has-data-[state=checked]:bg-primary/10 flex font-medium gap-2 group-data-[disabled=true]/field:opacity-50 group-data-[disabled=true]:opacity-50 group-data-[disabled=true]:pointer-events-none group/field-label has-[>[data-slot=field]]:border has-[>[data-slot=field]]:flex-col has-[>[data-slot=field]]:rounded-md has-[>[data-slot=field]]:w-full has-data-[state=checked]:bg-primary/5 has-data-[state=checked]:border-primary items-center leading-snug peer-disabled:cursor-not-allowed peer-disabled:opacity-50 peer/field-label select-none text-sm w-fit"
                             @on_mousedown> Password </label>
                      <a href="#"
                         class="hover:underline inline-block ml-auto text-sm underline-offset-4"> Forgot your password? </a>
                    </div>
                    <input type="password"
                           data-slot="input"
                           id="password"
                           required=""
                           class="aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-transparent border border-input dark:aria-invalid:ring-destructive/40 dark:bg-input/30 disabled:cursor-not-allowed disabled:opacity-50 disabled:pointer-events-none file:bg-transparent file:border-0 file:font-medium file:h-7 file:inline-flex file:text-foreground file:text-sm focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 h-9 md:text-sm min-w-0 outline-none placeholder:text-muted-foreground px-3 py-1 rounded-md selection:bg-primary selection:text-primary-foreground shadow-xs text-base transition-[color,box-shadow] w-full"/>
                  </div>
                  <div role="group"
                       data-slot="field"
                       data-orientation="vertical"
                       class="[&>*]:w-full [&>.sr-only]:w-auto data-[invalid=true]:text-destructive flex flex-col gap-3 group/field w-full">
                    <button type="submit"
                            data-slot="button"
                            data-variant="default"
                            data-size="default"
                            class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-primary/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-primary-foreground text-sm transition-all whitespace-nowrap"> Login </button>
                    <button type="button"
                            data-slot="button"
                            data-variant="outline"
                            data-size="default"
                            class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shadow-xs shrink-0 text-sm transition-all whitespace-nowrap"> Login with Google </button>
                    <p data-slot="field-description"
                       class="[&>a:hover]:text-primary [&>a]:underline [&>a]:underline-offset-4 [[data-variant=legend]+&]:-mt-1.5 font-normal group-has-[[data-orientation=horizontal]]/field:text-balance last:mt-0 leading-normal nth-last-2:-mt-1 text-center text-muted-foreground text-sm">
                      Don't have an account?
                      <a href="#"> Sign up </a>
                    </p>
                  </div>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
    |}]
;;

let%expect_test "login-01" =
  Block_summary.show (Block_summary.handle "login-01");
  [%expect
    {|
    slots:
      card
      card-header
      card-title
      card-description
      card-content
      field-group
      field x3
      field-label x2
      input x2
      button x2
      field-description
    text:
      Login to your account Enter your email below to login to your account Email
      Password Forgot your password? Login Login with Google Don't have an
      account? Sign up
    |}]
;;

let%expect_test "login-02" =
  Block_summary.show (Block_summary.handle "login-02");
  [%expect
    {|
    slots:
      field-group
      field x4
      field-label x2
      input x2
      button x2
      field-separator
      separator
      field-separator-content
      field-description
    text:
      Acme Inc. Login to your account Enter your email below to login to your
      account Email Password Forgot your password? Login Or continue with Login
      with GitHub Don't have an account? Sign up
    |}]
;;

let%expect_test "login-03" =
  Block_summary.show (Block_summary.handle "login-03");
  [%expect
    {|
    slots:
      card
      card-header
      card-title
      card-description
      card-content
      field-group
      field x4
      button x3
      field-separator
      separator
      field-separator-content
      field-label x2
      input x2
      field-description x2
    text:
      Acme Inc. Welcome back Login with your Apple or Google account Login with
      Apple Login with Google Or continue with Email Password Forgot your
      password? Login Don't have an account? Sign up By clicking continue, you
      agree to our Terms of Service and Privacy Policy .
    |}]
;;

let%expect_test "login-04" =
  Block_summary.show (Block_summary.handle "login-04");
  [%expect
    {|
    slots:
      card
      card-content
      field-group
      field x4
      field-label x2
      input x2
      button x4
      field-separator
      separator
      field-separator-content
      field-description x2
    text:
      Welcome back Login to your Acme Inc account Email Password Forgot your
      password? Login Or continue with Login with Apple Login with Google Login
      with Meta Don't have an account? Sign up By clicking continue, you agree to
      our Terms of Service and Privacy Policy .
    |}]
;;

let%expect_test "login-05" =
  Block_summary.show (Block_summary.handle "login-05");
  [%expect
    {|
    slots:
      field-group
      field-description x2
      field x3
      field-label
      input
      button x3
      field-separator
      separator
      field-separator-content
    text:
      Acme Inc. Welcome to Acme Inc. Don't have an account? Sign up Email Login Or
      Continue with Apple Continue with Google By clicking continue, you agree to
      our Terms of Service and Privacy Policy .
    |}]
;;

let%expect_test "signup-01" =
  Block_summary.show (Block_summary.handle "signup-01");
  [%expect
    {|
    slots:
      card
      card-header
      card-title
      card-description
      card-content
      field-group x2
      field x5
      field-label x4
      input x4
      field-description x4
      button x2
    text:
      Create an account Enter your information below to create your account Full
      Name Email We'll use this to contact you. We will not share your email with
      anyone else. Password Must be at least 8 characters long. Confirm Password
      Please confirm your password. Create Account Sign up with Google Already
      have an account? Sign in
    |}]
;;

let%expect_test "signup-02" =
  Block_summary.show (Block_summary.handle "signup-02");
  [%expect
    {|
    slots:
      field-group
      field x6
      field-label x4
      input x4
      field-description x4
      button x2
      field-separator
      separator
      field-separator-content
    text:
      Acme Inc. Create your account Fill in the form below to create your account
      Full Name Email We'll use this to contact you. We will not share your email
      with anyone else. Password Must be at least 8 characters long. Confirm
      Password Please confirm your password. Create Account Or continue with Sign
      up with GitHub Already have an account? Sign in
    |}]
;;

let%expect_test "signup-03" =
  Block_summary.show (Block_summary.handle "signup-03");
  [%expect
    {|
    slots:
      card
      card-header
      card-title
      card-description
      card-content
      field-group
      field x7
      field-label x4
      input x4
      field-description x3
      button
    text:
      Acme Inc. Create your account Enter your email below to create your account
      Full Name Email Password Confirm Password Must be at least 8 characters
      long. Create Account Already have an account? Sign in By clicking continue,
      you agree to our Terms of Service and Privacy Policy .
    |}]
;;

let%expect_test "signup-04" =
  Block_summary.show (Block_summary.handle "signup-04");
  [%expect
    {|
    slots:
      card
      card-content
      field-group
      field x7
      field-label x3
      input x3
      field-description x4
      button x4
      field-separator
      separator
      field-separator-content
    text:
      Create your account Enter your email below to create your account Email
      We'll use this to contact you. We will not share your email with anyone
      else. Password Confirm Password Must be at least 8 characters long. Create
      Account Or continue with Sign up with Apple Sign up with Google Sign up with
      Meta Already have an account? Sign in By clicking continue, you agree to our
      Terms of Service and Privacy Policy .
    |}]
;;

let%expect_test "signup-05" =
  Block_summary.show (Block_summary.handle "signup-05");
  [%expect
    {|
    slots:
      field-group
      field-description x2
      field x3
      field-label
      input
      button x3
      field-separator
      separator
      field-separator-content
    text:
      Acme Inc. Welcome to Acme Inc. Already have an account? Sign in Email Create
      Account Or Continue with Apple Continue with Google By clicking continue,
      you agree to our Terms of Service and Privacy Policy .
    |}]
;;
